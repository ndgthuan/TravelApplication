import 'dart:io';
import 'dart:typed_data';

// Interface cho dịch ảnh: pick từ gallery, gọi API dịch
abstract class IImageTranslationService {
  Future<File?> pickImage();

  Future<Uint8List?> translateImage(File imageFile, String targetLang);
}
