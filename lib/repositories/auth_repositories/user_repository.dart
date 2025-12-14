import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapgo/models/app_user.dart';
import 'package:snapgo/repositories/auth_repositories/auth_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return _userFromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  @override
  Stream<UserEntity?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return _userFromFirestore(doc);
    });
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(_userToFirestore(user));
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  @override
  Future<String> updateAvatar(String userId, String imagePath) async {
    // Implement with Firebase Storage
    throw UnimplementedError('Avatar upload not implemented yet');
  }

  @override
  Future<void> followUser(String userId, String targetUserId) async {
    try {
      final batch = _firestore.batch();

      // Update follower's following count
      batch.update(
        _firestore.collection('users').doc(userId),
        {'stats.following': FieldValue.increment(1)},
      );

      // Update target's followers count
      batch.update(
        _firestore.collection('users').doc(targetUserId),
        {'stats.followers': FieldValue.increment(1)},
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to follow user: ${e.toString()}');
    }
  }

  @override
  Future<void> unfollowUser(String userId, String targetUserId) async {
    try {
      final batch = _firestore.batch();

      batch.update(
        _firestore.collection('users').doc(userId),
        {'stats.following': FieldValue.increment(-1)},
      );

      batch.update(
        _firestore.collection('users').doc(targetUserId),
        {'stats.followers': FieldValue.increment(-1)},
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to unfollow user: ${e.toString()}');
    }
  }

  @override
  Future<List<UserEntity>> getFollowers(String userId) async {
    // Implement with separate followers collection
    throw UnimplementedError('Get followers not implemented yet');
  }

  @override
  Future<List<UserEntity>> getFollowing(String userId) async {
    // Implement with separate following collection
    throw UnimplementedError('Get following not implemented yet');
  }

  @override
  Future<List<UserEntity>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs.map(_userFromFirestore).toList();
    } catch (e) {
      throw Exception('Failed to search users: ${e.toString()}');
    }
  }

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
}