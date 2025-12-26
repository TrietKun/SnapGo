import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snapgo/blocs/upload/image_upload_event.dart';
import 'package:snapgo/blocs/upload/image_upload_state.dart';
import 'package:snapgo/services/cloudinary/cloudinary_service.dart';

class ImageUploadBloc extends Bloc<ImageUploadEvent, ImageUploadState> {
  ImageUploadBloc() : super(ImageUploadInitial()) {
    on<ImageSelected>(_onImageSelected);
    on<ImageUploadRequested>(_onImageUploadRequested);
    on<AvatarUploadRequested>(_onAvatarUploadRequested);
    on<ImageUploadCancelled>(_onImageUploadCancelled);
    on<ImageUploadReset>(_onImageUploadReset);
  }

  void _onImageSelected(
    ImageSelected event,
    Emitter<ImageUploadState> emit,
  ) {
    emit(ImagePreview(event.imagePath));
  }

  Future<void> _onImageUploadRequested(
    ImageUploadRequested event,
    Emitter<ImageUploadState> emit,
  ) async {
    try {
      emit(ImageUploading(localPath: event.imagePath, progress: 0.0));

      await Future.delayed(const Duration(milliseconds: 200));
      emit(ImageUploading(localPath: event.imagePath, progress: 0.3));

      // Upload ảnh
      final uploadedUrl = await CloudinaryService.uploadImage(
        File(event.imagePath),
        event.folder ?? 'uploads',
      );

      emit(ImageUploading(localPath: event.imagePath, progress: 0.9));
      await Future.delayed(const Duration(milliseconds: 200));

      // Extract publicId từ URL
      final publicId = CloudinaryService.getPublicIdFromUrl(uploadedUrl) ?? '';

      emit(ImageUploading(localPath: event.imagePath, progress: 1.0));
      await Future.delayed(const Duration(milliseconds: 100));

      emit(ImageUploadSuccess(
        uploadedUrl: uploadedUrl,
        publicId: publicId,
        localPath: event.imagePath,
      ));
    } catch (e) {
      emit(ImageUploadFailure(
        error: e.toString().replaceAll('Exception: ', ''),
        localPath: event.imagePath,
      ));
    }
  }

  Future<void> _onAvatarUploadRequested(
    AvatarUploadRequested event,
    Emitter<ImageUploadState> emit,
  ) async {
    try {
      emit(ImageUploading(localPath: event.imagePath, progress: 0.0));

      await Future.delayed(const Duration(milliseconds: 200));
      emit(ImageUploading(localPath: event.imagePath, progress: 0.3));

      // Upload avatar
      final uploadedUrl = await CloudinaryService.uploadImage(
        File(event.imagePath),
        event.folder,
      );

      emit(ImageUploading(localPath: event.imagePath, progress: 0.9));
      await Future.delayed(const Duration(milliseconds: 200));

      final publicId = CloudinaryService.getPublicIdFromUrl(uploadedUrl) ?? '';

      emit(ImageUploading(localPath: event.imagePath, progress: 1.0));
      await Future.delayed(const Duration(milliseconds: 100));

      emit(ImageUploadSuccess(
        uploadedUrl: uploadedUrl,
        publicId: publicId,
        localPath: event.imagePath,
      ));
    } catch (e) {
      emit(ImageUploadFailure(
        error: e.toString().replaceAll('Exception: ', ''),
        localPath: event.imagePath,
      ));
    }
  }

  void _onImageUploadCancelled(
    ImageUploadCancelled event,
    Emitter<ImageUploadState> emit,
  ) {
    emit(ImageUploadInitial());
  }

  void _onImageUploadReset(
    ImageUploadReset event,
    Emitter<ImageUploadState> emit,
  ) {
    emit(ImageUploadInitial());
  }
}