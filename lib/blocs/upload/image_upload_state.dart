import 'package:equatable/equatable.dart';

abstract class ImageUploadState extends Equatable {
  const ImageUploadState();

  @override
  List<Object?> get props => [];
}

class ImageUploadInitial extends ImageUploadState {}

class ImagePreview extends ImageUploadState {
  final String localPath;

  const ImagePreview(this.localPath);

  @override
  List<Object?> get props => [localPath];
}

class ImageUploading extends ImageUploadState {
  final String localPath;
  final double progress; // 0.0 - 1.0

  const ImageUploading({
    required this.localPath,
    this.progress = 0.0,
  });

  @override
  List<Object?> get props => [localPath, progress];
}

class ImageUploadSuccess extends ImageUploadState {
  final String uploadedUrl;
  final String publicId;
  final String localPath;

  const ImageUploadSuccess({
    required this.uploadedUrl,
    required this.publicId,
    required this.localPath,
  });

  @override
  List<Object?> get props => [uploadedUrl, publicId, localPath];
}

class ImageUploadFailure extends ImageUploadState {
  final String error;
  final String? localPath;

  const ImageUploadFailure({
    required this.error,
    this.localPath,
  });

  @override
  List<Object?> get props => [error, localPath];
}