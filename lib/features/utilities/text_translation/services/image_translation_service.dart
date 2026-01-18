import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageTranslationService {
  // Dùng localhost vì đã adb reverse tcp:5000 tcp:5000
  static const String _baseUrl = 'http://localhost:5000';
  final _imagePicker = ImagePicker();

  Future<File?> pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  Future<Uint8List?> translateImage(File imageFile, String targetLang) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('translateImage: Sending request...');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/translate-image'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'image': base64Image, 'target_lang': targetLang}),
          )
          .timeout(Duration(seconds: 120));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['image'] != null) {
          print('translateImage: Success!');
          return base64Decode(data['image']);
        }
      }
      print('translateImage: Response error: ${response.statusCode}');
      return null;
    } catch (e) {
      print('translateImage: Error - $e');
      return null;
    }
  }
}
