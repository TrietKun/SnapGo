// lib/repositories/profile/firebase_profile_repository.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:snapgo/models/user_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:snapgo/repositories/user_repositories.dart/profile_repository.dart';

class FirebaseProfileRepository implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  FirebaseProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      // Prepare update data
      final Map<String, dynamic> updateData = {};
      
      if (displayName != null) {
        updateData['displayName'] = displayName;
      }
      
      if (bio != null) {
        updateData['bio'] = bio;
      }
      
      if (avatarUrl != null) {
        updateData['avatarUrl'] = avatarUrl;
      }
      
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      // Update Firestore
      await _firestore.collection('users').doc(userId).update(updateData);

      // Update FirebaseAuth display name if provided
      if (displayName != null) {
        await _auth.currentUser?.updateDisplayName(displayName);
      }

      // Update FirebaseAuth photo URL if provided
      if (avatarUrl != null) {
        await _auth.currentUser?.updatePhotoURL(avatarUrl);
      }

      // Fetch updated user
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return Left(Failure('User not found'));
      }

      final userData = userDoc.data()!;
      final updatedUser = UserEntity.fromJson({
        'id': userDoc.id,
        ...userData,
      });

      return Right(updatedUser);
    } on FirebaseException catch (e) {
      return Left(Failure('Firebase error: ${e.message ?? e.code}'));
    } catch (e) {
      return Left(Failure('Failed to update profile: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required String imagePath,
  }) async {
    try {
      final file = File(imagePath);
      
      if (!file.existsSync()) {
        return Left(Failure('Image file not found'));
      }

      // Create unique filename
      final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('avatars/$userId/$fileName');

      // Upload file
      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(Failure('Upload failed: ${e.message ?? e.code}'));
    } catch (e) {
      return Left(Failure('Failed to upload avatar: $e'));
    }
  }
}