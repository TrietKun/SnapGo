import 'package:snapgo/models/user_entity.dart';

abstract class EditProfileState {}

class EditProfileInitial extends EditProfileState {}

class EditProfileLoading extends EditProfileState {}

class EditProfileSuccess extends EditProfileState {
  final UserEntity user;

  EditProfileSuccess(this.user);
}

class EditProfileFailure extends EditProfileState {
  final String message;

  EditProfileFailure(this.message);
}

class EditProfileAvatarUpdated extends EditProfileState {
  final String avatarUrl;

  EditProfileAvatarUpdated(this.avatarUrl);
}