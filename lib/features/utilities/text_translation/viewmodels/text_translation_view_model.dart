// Mục đích của file này quản lý state và logic cho TextTranslationScreen
// UI chỉ gọi method và lắng nghe state, không xử lý logic
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/domain/services/i_translation_service.dart';
import 'package:travel_app/domain/repositories/i_language_repository.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:travel_app/domain/services/i_speech_tts_service.dart';
import 'package:travel_app/domain/services/i_image_translation_service.dart';
import 'package:travel_app/domain/models/language_model.dart';
import 'package:travel_app/domain/repositories/i_user_repository.dart';

class TextTranslationViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final ISpeechTtsService _speechTtsService;
  final IImageTranslationService _imageTranslationService;
  final IUserRepository _userRepository;
  final ILanguageRepository _languageRepository;
  final ITranslationService _translationService;

  TextTranslationViewModel(
    this._speechTtsService,
    this._imageTranslationService,
    this._userRepository,
    this._languageRepository,
    this._translationService,
  );

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

  // Image translation state
  Uint8List? _originalImageBytes;
  Uint8List? _translatedImageBytes;
  File? _selectedImageFile;
  bool _isTranslatingImage = false;

  // Search state
  String _searchQuery = '';

  // Ngôn ngữ nguồn và đích
  List<LanguageModel> _supportedLanguages = [];
  LanguageModel _sourceLanguage = LanguageModel(
    code: 'auto',
    name: 'Auto Detect',
    flag: '🌐',
  );
  LanguageModel _targetLanguage = LanguageModel(
    code: 'vi',
    name: 'Vietnamese',
    flag: '🇻🇳',
  );

  //==========================================================================//
  //                        GETTERS                                           //
  //==========================================================================//
  // Gọi method để gọi qua UI
  bool get isListening => _isListening;
  bool get isCopied => _isCopied;
  bool get isLoadingLanguages => _isLoadingLanguages;
  bool get isTranslating => _isTranslating;
  String get translatedText => _translatedText;
  String get errorMessage => _errorMessage;
  Uint8List? get originalImageBytes => _originalImageBytes;
  Uint8List? get translatedImageBytes => _translatedImageBytes;
  bool get isTranslatingImage => _isTranslatingImage;
  String get searchQuery => _searchQuery;
  List<LanguageModel> get supportedLanguages => _supportedLanguages;
  LanguageModel get sourceLanguage => _sourceLanguage;
  LanguageModel get targetLanguage => _targetLanguage;

  // Kiểm tra có thể swap ngôn ngữ không (không cho swap nếu có auto detect)
  bool get canSwapLanguages =>
      _sourceLanguage.code != 'auto' && _targetLanguage.code != 'auto';

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Reset all state when leaving screen
  void reset() {
    _translatedText = '';
    _errorMessage = '';
    _isCopied = false;
    _isListening = false;
    _isTranslating = false;
    _originalImageBytes = null;
    _translatedImageBytes = null;
    _selectedImageFile = null;
    _isTranslatingImage = false;
    notifyListeners();
  }

  // Clear image (khi tap nút X)
  void clearImage() {
    _originalImageBytes = null;
    _translatedImageBytes = null;
    _selectedImageFile = null;
    notifyListeners();
  }

  // Load danh sách ngôn ngữ từ models
  Future<void> loadLanguages() async {
    if (!_isLoadingLanguages) return;

    try {
      _supportedLanguages = await _languageRepository.getSupportedLanguages();

      final user = await _userRepository.getCurrentUser();
      if (user?.preferredLanguage != null) {
        final savedLang = _supportedLanguages.firstWhere(
          (lang) => lang.code == user!.preferredLanguage,
          orElse: () => _targetLanguage,
        );
        _targetLanguage = savedLang;
      }
    } catch (e) {
      log('ERROR LOADING LANGUAGE PREFERENCES: $e');
    }

    _isLoadingLanguages = false;
    notifyListeners();
  }

  // Lọc ngôn ngữ theo search query
  List<LanguageModel> get filteredLanguages {
    if (_searchQuery.isEmpty) {
      return _supportedLanguages;
    }
    return _supportedLanguages.where((lang) {
      final name = lang.name.toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q);
    }).toList();
  }

  // Cập nhật search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Dịch văn bản
  Future<void> translateText(String inputText) async {
    if (inputText.trim().isEmpty) return;

    _isTranslating = true;
    notifyListeners();

    try {
      _translatedText = await _translationService.translate(
        inputText,
        from: _sourceLanguage.code,
        to: _targetLanguage.code,
      );
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
  void selectLanguage(LanguageModel lang, bool isSource) {
    if (isSource) {
      _sourceLanguage = lang;
    } else {
      _targetLanguage = lang;
      _saveLanguagePreference(lang.code);
    }
    notifyListeners();
  }

  Future<void> _saveLanguagePreference(String? code) async {
    if (code == null) return;
    try {
      await _userRepository.updateUser({'preferredLanguage': code});
    } catch (e) {
      log("ERROR SAVING LAGUAGE PREFERENCES: $e");
    }
  }

  // Speech-to-text: Bắt đầu nghe
  Future<void> startListening(Function(String) onResult) async {
    bool available = await _speechTtsService.initialize();
    if (available) {
      _isListening = true;
      _speechTtsService.listen(
        onResult: onResult,
        localeId: _sourceLanguage.code,
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
    _speechTtsService.speak(text, _targetLanguage.code);
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

  // Pick image từ gallery
  Future<void> pickImageFromGallery() async {
    final file = await _imageTranslationService.pickImage();
    if (file != null) {
      _selectedImageFile = file;
      _originalImageBytes = await file.readAsBytes();
      _translatedImageBytes = null;
      notifyListeners();
    }
  }

  // Dịch ảnh
  Future<void> translateImage() async {
    if (_selectedImageFile == null) {
      log('TRANSLATE: NO IMAGE FOUND');
      return;
    }

    log('TRANSLATE: STARTING TRANSLATION...');
    _isTranslatingImage = true;
    notifyListeners();

    try {
      final result = await _imageTranslationService.translateImage(
        _selectedImageFile!,
        _targetLanguage.code,
      );
      _translatedImageBytes = result;
    } catch (e) {
      _errorMessage = 'image_translation.error';
    } finally {
      _isTranslatingImage = false;
      notifyListeners();
    }
  }
}
