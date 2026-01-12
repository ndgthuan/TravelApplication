import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  static final cloudinary = CloudinaryPublic(
    'dj8iwwxw5',
    'travel_app_avatars',
    cache: false,
  );

  static Future<String?> uploadImage(File image) async {
    try {
      // Folder trên cloudinary
      final respone = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(image.path, folder: 'avatars'),
      );
      return respone.secureUrl;
    } catch (e) {
      // ignore: avoid_print
      print('CLOUDINARY ERROR: $e');
      return null;
    }
  }
}
