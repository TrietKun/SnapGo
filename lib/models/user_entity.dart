import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Immutable user entity with proper value semantics
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final UserRole role;
  final UserStats stats;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final List<String> badges;

  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.bio,
    required this.role,
    required this.stats,
    required this.createdAt,
    this.lastActiveAt,
    this.badges = const [],
  });

  bool get isGuest => role == UserRole.guest;
  bool get isVerified => role == UserRole.verified || role == UserRole.admin;
  String get username => displayName ?? email.split('@')[0];

  /// Factory for guest users
  factory UserEntity.guest() {
    return UserEntity(
      id: 'guest',
      email: 'guest@snapgo.app',
      displayName: 'Guest',
      role: UserRole.guest,
      stats: const UserStats.empty(),
      createdAt: DateTime.now(),
    );
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    String? bio,
    UserRole? role,
    UserStats? stats,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    List<String>? badges,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      role: role ?? this.role,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      badges: badges ?? this.badges,
    );
  }

  // Create a UserEntity from JSON
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      role: UserRole.values.firstWhere(
          (e) => e.toString() == 'UserRole.${json['role'] as String}',
          orElse: () => UserRole.user),
      stats: UserStats(
        followers: json['stats']?['followers'] as int? ?? 0,
        following: json['stats']?['following'] as int? ?? 0,
        posts: json['stats']?['posts'] as int? ?? 0,
        spotsVisited: json['stats']?['spotsVisited'] as int? ?? 0,
        photosShared: json['stats']?['photosShared'] as int? ?? 0,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      lastActiveAt: json['lastActiveAt'] != null
          ? (json['lastActiveAt'] as Timestamp).toDate()
          : null,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        avatarUrl,
        bio,
        role,
        stats,
        createdAt,
        lastActiveAt,
        badges,
      ];

  get phoneNumber => null;
}

enum UserRole {
  guest,
  user,
  verified,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.guest:
        return 'Guest';
      case UserRole.user:
        return 'Explorer';
      case UserRole.verified:
        return 'Verified Explorer';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

class UserStats extends Equatable {
  final int followers;
  final int following;
  final int posts;
  final int spotsVisited;
  final int photosShared;

  const UserStats({
    required this.followers,
    required this.following,
    required this.posts,
    this.spotsVisited = 0,
    this.photosShared = 0,
  });

  const UserStats.empty()
      : followers = 0,
        following = 0,
        posts = 0,
        spotsVisited = 0,
        photosShared = 0;

  @override
  List<Object?> get props => [
        followers,
        following,
        posts,
        spotsVisited,
        photosShared,
      ];
}
