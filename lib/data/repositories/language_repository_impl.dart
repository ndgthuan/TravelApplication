// Hàm này là hàm xử lý logic từ phương thức i_language_repository
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:travel_app/domain/repositories/i_language_repository.dart';

class LanguageRepositoryImpl implements ILanguageRepository {
  @override
  Future<List<Map<String, dynamic>>> getSupportedLanguages() async {
    final String jsonString = await rootBundle.loadString(
      'lib/assets/data/supported_languages.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.cast<Map<String, dynamic>>();
  }
}
