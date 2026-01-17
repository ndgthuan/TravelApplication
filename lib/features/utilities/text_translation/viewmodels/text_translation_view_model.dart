// Mục đích của file này quản lý state và login cho CurrencyExchangeScreen
// UI chỉ gọi method và lắng nghe state, không xử lý logic
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:translator/translator.dart';
import 'dart:convert';
import 'package:travel_app/features/utilities/text_translation/services/speech_tts_service.dart';

class TextTranslationViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final SpeechTtsService _speechTtsService;
  TextTranslationViewModel(this._speechTtsService);

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  // Khai báo các biến từ UI
  bool _isListening = false;
  bool _isCopied = false;
  bool _isLoadingLanguages = true;
  bool _isTranslating = false;
  String _translatedText = '';
  String _errorMessage = '';

  // Ngôn ngữ nguồn và đích
  List<Map<String, dynamic>> _supportedLanguages = [];
  Map<String, dynamic> _sourceLanguage = {
    'code': 'auto',
    'name': 'Auto Detect',
    'flag': '🌐',
  }; // Tự phát hiện ngôn ngữ
  Map<String, dynamic> _targetLanguage = {
    'code': 'vi',
    'name': 'Tiếng Việt',
    'flag': 'VN',
  }; // Tiếng việt

  // Gọi method để gọi qua UI
  bool get isListening => _isListening;
  bool get isCopied => _isCopied;
  bool get isLoadingLanguages => _isLoadingLanguages;
  bool get isTranslating => _isTranslating;
  String get translatedText => _translatedText;
  String get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get supportedLanguages => _supportedLanguages;
  Map<String, dynamic> get sourceLanguage => _sourceLanguage;
  Map<String, dynamic> get targetLanguage => _targetLanguage;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Translator instance
  final _translator = GoogleTranslator();

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Load danh sách ngôn ngữ từ JSON
  Future<void> loadLanguages() async {
    final String jsonString = await rootBundle.loadString(
      'lib/assets/data/supported_languages.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);

    _supportedLanguages = jsonData.cast<Map<String, dynamic>>();
    _isLoadingLanguages = false;

    // Ngôn ngữ mặc định
    if (_supportedLanguages.isNotEmpty) {
      _sourceLanguage = _supportedLanguages[0];
      _targetLanguage = _supportedLanguages.length > 1
          ? _supportedLanguages[1]
          : _supportedLanguages[0];
    }
    notifyListeners();
  }

  // Dịch văn bản
  Future<void> translateText(String inputText) async {
    if (inputText.trim().isEmpty) return;

    _isTranslating = true;
    notifyListeners();

    try {
      final translation = await _translator.translate(
        inputText,
        from: _sourceLanguage['code']!,
        to: _targetLanguage['code']!,
      );
      _translatedText = translation.text;
      _isTranslating = false;
      notifyListeners();
    } catch (e) {
      _isTranslating = false;
      _errorMessage = 'translation.error'.tr();
      notifyListeners();
    }
  }

  // Swap ngôn ngữ
  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    notifyListeners();
  }

  // Chọn ngôn ngữ
  void selectLanguage(Map<String, dynamic> lang, bool isSource) {
    if (isSource) {
      _sourceLanguage = lang;
    } else {
      _targetLanguage = lang;
    }
    notifyListeners();
  }

  // Speech-to-text: Bắt đầu nghe
  Future<void> startListening(Function(String) onResult) async {
    bool available = await _speechTtsService.initialize();
    if (available) {
      _isListening = true;
      _speechTtsService.listen(
        onResult: onResult,
        localeId: _sourceLanguage['code'] ?? 'vi',
      );
      notifyListeners();
    }
  }

  // Speech-to-text: Dừng nghe
  void stopListening() {
    _speechTtsService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  // Text-to-speech: Đọc văn bản
  void speak(String text) {
    _speechTtsService.speak(text, _targetLanguage['code'] ?? 'en');
  }

  // Sao chép vào clipboard
  void copyToClipboard(String text) {
    _speechTtsService.copyToClipboard(text);
    _isCopied = true;
    notifyListeners();

    Future.delayed(Duration(seconds: 2), () {
      _isCopied = false;
      notifyListeners();
    });
  }
}
