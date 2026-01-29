import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:travel_app/domain/services/i_cloudinary_service.dart';

class CloudinaryService implements ICloudinaryService {
  final _cloudinary = CloudinaryPublic(
    'dj8iwwxw5',
    'travel_app_avatars',
    cache: false,
  );

  @override
  Future<String?> uploadImage(File image) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: 'avatars'),
      );
      return response.secureUrl;
    } catch (e) {
      // ignore: avoid_print
      print('CLOUDINARY ERROR: $e');
      return null;
    }
  }
}
