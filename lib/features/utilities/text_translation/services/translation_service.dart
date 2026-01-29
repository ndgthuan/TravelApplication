// Khởi tạo các phương thức dịch văn bản
import 'package:translator/translator.dart';
import 'package:travel_app/domain/services/i_translation_service.dart';

class TranslationService implements ITranslationService {
  final GoogleTranslator _translator = GoogleTranslator();

  @override
  Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    final translation = await _translator.translate(text, from: from, to: to);
    return translation.text;
  }
}
