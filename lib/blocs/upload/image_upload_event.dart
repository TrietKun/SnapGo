import 'package:equatable/equatable.dart';

abstract class ImageUploadEvent extends Equatable {
  const ImageUploadEvent();

  @override
  List<Object?> get props => [];
}

class ImageSelected extends ImageUploadEvent {
  final String imagePath;

  const ImageSelected(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class ImageUploadRequested extends ImageUploadEvent {
  final String imagePath;
  final String? folder;

  const ImageUploadRequested({
    required this.imagePath,
    this.folder,
  });

  @override
  List<Object?> get props => [imagePath, folder];
}

class AvatarUploadRequested extends ImageUploadEvent {
  final String imagePath;
  final String folder;

  const AvatarUploadRequested({
    required this.imagePath,
    this.folder = 'avatars',
  });

  @override
  List<Object?> get props => [imagePath, folder];
}

class ImageUploadCancelled extends ImageUploadEvent {}

class ImageUploadReset extends ImageUploadEvent {}