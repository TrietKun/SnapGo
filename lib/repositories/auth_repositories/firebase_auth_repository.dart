import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:snapgo/models/app_user.dart';
import 'package:snapgo/repositories/auth_repositories/auth_repository.dart';


class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;

      return _userFromFirestore(userDoc);
    } catch (e) {
      throw AuthException('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) return null;

      return _userFromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return null;

      // Create user document in Firestore
      final user = UserEntity(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        role: UserRole.user,
        stats: const UserStats.empty(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.id)
          .set(_userToFirestore(user));

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = 
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) return null;

      // Check if user exists
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return _userFromFirestore(userDoc);
      }

      // Create new user
      final user = UserEntity(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!,
        displayName: userCredential.user!.displayName,
        avatarUrl: userCredential.user!.photoURL,
        role: UserRole.user,
        stats: const UserStats.empty(),
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.id)
          .set(_userToFirestore(user));

      return user;
    } catch (e) {
      throw AuthException('Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserEntity?> signInWithApple() async {
    // Implement Apple Sign In
    throw UnimplementedError('Apple Sign In not implemented yet');
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw AuthException('No user logged in');

      // Delete user document
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete auth account
      await user.delete();
    } catch (e) {
      throw AuthException('Account deletion failed: ${e.toString()}');
    }
  }

  // Helper methods
  UserEntity _userFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserEntity(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      avatarUrl: data['avatarUrl'],
      bio: data['bio'],
      role: UserRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => UserRole.user,
      ),
      stats: UserStats(
        followers: data['stats']?['followers'] ?? 0,
        following: data['stats']?['following'] ?? 0,
        posts: data['stats']?['posts'] ?? 0,
        spotsVisited: data['stats']?['spotsVisited'] ?? 0,
        photosShared: data['stats']?['photosShared'] ?? 0,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActiveAt: data['lastActiveAt'] != null
          ? (data['lastActiveAt'] as Timestamp).toDate()
          : null,
      badges: List<String>.from(data['badges'] ?? []),
    );
  }

  Map<String, dynamic> _userToFirestore(UserEntity user) {
    return {
      'email': user.email,
      'displayName': user.displayName,
      'avatarUrl': user.avatarUrl,
      'bio': user.bio,
      'role': user.role.name,
      'stats': {
        'followers': user.stats.followers,
        'following': user.stats.following,
        'posts': user.stats.posts,
        'spotsVisited': user.stats.spotsVisited,
        'photosShared': user.stats.photosShared,
      },
      'createdAt': Timestamp.fromDate(user.createdAt),
      'lastActiveAt': user.lastActiveAt != null
          ? Timestamp.fromDate(user.lastActiveAt!)
          : null,
      'badges': user.badges,
    };
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication error: $code';
    }
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}