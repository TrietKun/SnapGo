import 'package:snapgo/models/user_entity.dart';

abstract class AuthRepository {
  /// Get currently authenticated user
  Future<UserEntity?> getCurrentUser();

  /// Sign in with email and password
  Future<UserEntity?> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<UserEntity?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Sign in with Google
  Future<UserEntity?> signInWithGoogle();

  /// Sign in with Apple
  Future<UserEntity?> signInWithApple();

  /// Reset password
  Future<void> resetPassword(String email);

  /// Delete account
  Future<void> deleteAccount();
}

// lib/repositories/user_repository.dart

/// User repository interface for user data operations
abstract class UserRepository {
  /// Get user by ID
  Future<UserEntity?> getUser(String userId);

  /// Get user stream for real-time updates
  Stream<UserEntity?> getUserStream(String userId);

  /// Update user profile
  Future<void> updateUser(UserEntity user);

  /// Update user avatar
  Future<String> updateAvatar(String userId, String imagePath);

  /// Follow/unfollow user
  Future<void> followUser(String userId, String targetUserId);
  Future<void> unfollowUser(String userId, String targetUserId);

  /// Get user followers/following
  Future<List<UserEntity>> getFollowers(String userId);
  Future<List<UserEntity>> getFollowing(String userId);

  /// Search users
  Future<List<UserEntity>> searchUsers(String query);
}