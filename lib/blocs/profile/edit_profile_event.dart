abstract class EditProfileEvent {}

class EditProfileSubmitted extends EditProfileEvent {
  final String userId;
  final String? displayName;
  final String? bio;
  final String? avatarPath; // path local

  EditProfileSubmitted({
    required this.userId,
    this.displayName,
    this.bio,
    this.avatarPath,
  });
}

class AvatarUploaded extends EditProfileEvent {
  final String userId;
  final String avatarUrl;

  AvatarUploaded({
    required this.userId,
    required this.avatarUrl,
  });
}

enum EditProfileStatus {
  initial,
  loading,
  success,
  failure,
}
