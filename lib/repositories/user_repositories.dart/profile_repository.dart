import 'package:snapgo/models/user_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? avatarUrl,
  });

  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required String imagePath,
  });
}

//class failure
class Failure {
  final String message;

  Failure(this.message);
}
