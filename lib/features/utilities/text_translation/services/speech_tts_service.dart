// Mục đích của trang service này là chứa các method thực hiện
// Các method gồm nghe, chuyển văn bản thành giọng nói, giọng nói thành chữ,...
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:travel_app/domain/services/i_speech_tts_service.dart';

class SpeechTtsService implements ISpeechTtsService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  // Khởi tạo
  @override
  Future<bool> initialize() => _speech.initialize();

  // Nghe âm thanh để chuyển thành văn bản
  @override
  void listen({required Function(String) onResult, required String localeId}) {
    _speech.listen(
      onResult: (result) => onResult(result.recognizedWords),
      localeId: localeId,
    );
  }

  @override
  void stopListening() => _speech.stop();

  // Chuyển đổi văn bản thành giọng nói
  @override
  Future<void> speak(String text, String languageCode) async {
    if (text.isEmpty) return;
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.speak(text);
  }

  // Clipboard
  @override
  void copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
  }
}
