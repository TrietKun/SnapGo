import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapgo/blocs/profile/edit_profile_event.dart';
import 'package:snapgo/blocs/profile/edit_profile_state.dart';
import 'package:snapgo/repositories/user_repositories.dart/FirebaseProfileRepository.dart';
import 'package:snapgo/repositories/user_repositories.dart/profile_repository.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final ProfileRepository _repository;

  EditProfileBloc({ProfileRepository? repository})
      : _repository = repository ?? FirebaseProfileRepository(),
        super(EditProfileInitial()) {
    on<EditProfileSubmitted>(_onSubmit);
    on<AvatarUploaded>(_onAvatarUploaded);
  }

  Future<void> _onSubmit(
    EditProfileSubmitted event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(EditProfileLoading());

    final result = await _repository.updateProfile(
      userId: event.userId,
      displayName: event.displayName,
      bio: event.bio,
      avatarUrl: event.avatarPath,
    );

    result.fold(
      (failure) => emit(EditProfileFailure(failure.message)),
      (user) => emit(EditProfileSuccess(user)),
    );
  }

  Future<void> _onAvatarUploaded(
    AvatarUploaded event,
    Emitter<EditProfileState> emit,
  ) async {
    try {
      emit(EditProfileLoading());

      await _repository.updateProfile(
        userId: event.userId,
        avatarUrl: event.avatarUrl,
      );

      emit(EditProfileAvatarUpdated(event.avatarUrl));
    } catch (e) {
      emit(EditProfileFailure('Update avatar failed'));
    }
  }
}
