// Hàm này là hàm xử lý logic từ phương thức i_language_repository
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:travel_app/domain/repositories/i_language_repository.dart';
import 'package:travel_app/domain/models/language_model.dart';

class LanguageRepositoryImpl implements ILanguageRepository {
  @override
  Future<List<LanguageModel>> getSupportedLanguages() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/assets/data/supported_languages.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.map((item) => LanguageModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to load supported languages: $e');
    }
  }
}
