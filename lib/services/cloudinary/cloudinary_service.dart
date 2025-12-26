import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dkwb3ddwa', // Thay bằng cloud name của bạn
    'dateplanning_app_uploads', // Thay bằng upload preset của bạn
    cache: false,
  );

  /// Upload ảnh lên Cloudinary
  /// 
  /// [imageFile] - File ảnh cần upload
  /// [folder] - Folder trên Cloudinary (vd: 'avatars', 'posts')
  /// 
  /// Returns: Secure URL của ảnh đã upload
  static Future<String> uploadImage(File imageFile, String folder) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Xóa ảnh từ Cloudinary
  /// 
  /// [publicId] - Public ID của ảnh (extract từ URL bằng getPublicIdFromUrl)
  // static Future<void> deleteImage(String publicId) async {
  //   try {
  //     await cloudinary.deleteFile(
  //       url: publicId,
  //       resourceType: CloudinaryResourceType.Image,
  //       invalidate: true,
  //     );
  //   } catch (e) {
  //     throw Exception('Failed to delete image: $e');
  //   }
  // }

  /// Extract public_id từ Cloudinary URL
  /// 
  /// Example: 
  /// URL: https://res.cloudinary.com/demo/image/upload/v1234/avatars/user123.jpg
  /// Returns: avatars/user123
  static String? getPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      final indexOfUpload = pathSegments.indexOf('upload');
      
      if (indexOfUpload != -1 && pathSegments.length > indexOfUpload + 2) {
        final publicIdWithExtension =
            pathSegments.sublist(indexOfUpload + 2).join('/');
        return publicIdWithExtension.split('.').first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}