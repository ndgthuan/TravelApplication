import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator/translator.dart';
import 'package:travel_app/screen/Account/widgets/translate_button_widget.dart';
import 'package:travel_app/screen/Account/widgets/translate_board_widget.dart';
import 'dart:convert';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, rootBundle;
import 'package:easy_localization/easy_localization.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  // Speech to text
  late stt.SpeechToText _speech;
  bool _isListening = false;

  // Text to speech
  late FlutterTts _flutterTts;

  // Biến copy
  bool _isCopied = false;

  // Biến loading
  bool _isLoadingLanguages = true;
  // Biến lưu danh sách ngôn ngữ
  List<Map<String, dynamic>> supportedLanguages = [];

  // Hàm load từ JSON
  Future<void> loadLanguages() async {
    final String jsonString = await rootBundle.loadString(
      'lib/assets/data/supported_languages.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      supportedLanguages = jsonData.cast<Map<String, dynamic>>();
      _isLoadingLanguages = false;

      // Ngôn ngữ mặc định khi mới vào trang
      if (supportedLanguages.isNotEmpty) {
        _sourceLanguage = supportedLanguages[0];
        _targetLanguage = supportedLanguages.length > 1
            ? supportedLanguages[1]
            : supportedLanguages[0];
      }
    });
  }

  // Translator
  final translator = GoogleTranslator();

  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  // Trạng thái
  bool _isTranslating = false;

  // Ngôn ngữ nguồn và đích
  Map<String, dynamic> _sourceLanguage = {
    'code': 'vi',
    'name': 'Tiếng Việt',
    'flag': 'VN',
  }; // Tiếng Việt
  Map<String, dynamic> _targetLanguage = {
    'code': 'en',
    'name': 'English',
    'flag': 'GB',
  }; // English

  @override
  void initState() {
    super.initState();
    loadLanguages();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  // Hàm copy
  void _copyToClipboard() {
    if (_outputController.text.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _outputController.text));
    setState(() => _isCopied = true);

    // Reset về icon copy sau 2 giây
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isCopied = false);
      }
    });
  }

  // Hàm dịch văn bản
  Future<void> _translateText() async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final translation = await translator.translate(
        _inputController.text,
        from: _sourceLanguage['code']!,
        to: _targetLanguage['code']!,
      );

      if (!mounted) return;
      setState(() {
        _outputController.text = translation.text;
        _isTranslating = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTranslating = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('translation.error'.tr())));
    }
  }

  // Hàm speech-to-text cho mic
  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _inputController.text = result.recognizedWords;
          });
        },
        localeId: _sourceLanguage['code'], // Ngôn ngữ nguồn
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  // Hàm đọc
  Future<void> _speak(String text, String languageCode) async {
    if (text.isEmpty) return;
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.speak(text);
  }

  // Hiển thị bottom sheet chọn ngôn ngữ
  void _showLanguagePicker(bool isSource) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1C1C1D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isSource
                    ? 'translation.choose_source'.tr()
                    : 'translation.choose_target'.tr(),
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 15),
              Flexible(
                child: _isLoadingLanguages
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFAD35),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: supportedLanguages.length,
                        itemBuilder: (context, index) {
                          final lang = supportedLanguages[index];
                          final isSelected = isSource
                              ? lang['code'] == _sourceLanguage['code']
                              : lang['code'] == _targetLanguage['code'];
                          return ListTile(
                            leading: Text(
                              lang['flag']!,
                              style: TextStyle(fontSize: 24),
                            ),
                            title: Text(
                              lang['name']!,
                              style: GoogleFonts.beVietnamPro(
                                color: isSelected
                                    ? Color(0xFFFFAD35)
                                    : Colors.white,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: Color(0xFFFFAD35),
                                  )
                                : null,
                            onTap: () {
                              setState(() {
                                if (isSource) {
                                  _sourceLanguage = lang;
                                } else {
                                  _targetLanguage = lang;
                                }
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'translation.title'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent,
        backgroundColor: Color(0xFF1C1c1D),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            children: [
              TranslateBoardWidget(
                boardText: 'translation.input_hint'.tr(),
                formerIcon: Icons.camera_alt,
                latterIcon: _isListening ? Icons.mic_off : Icons.mic,
                controller: _inputController,
                onFormerIconTap: () {},
                onLatterIconTap: () {
                  if (_isListening) {
                    _stopListening();
                  } else {
                    _startListening();
                  }
                },
              ),
              const SizedBox(height: 20),

              // 2 hộp chuyển đổi ngôn ngữ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TranslateButtonWidget(
                      languageCode: _sourceLanguage['code']! ?? '',
                      languageName: _sourceLanguage['name']! ?? '',
                      flag: _sourceLanguage['flag']! ?? '',
                      onTap: () => _showLanguagePicker(true),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      // Swap ngôn ngữ
                      setState(() {
                        final temp = _sourceLanguage;
                        _sourceLanguage = _targetLanguage;
                        _targetLanguage = temp;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        color: Color(0xFFFFAD35),
                      ),
                    ),
                  ),

                  Expanded(
                    child: TranslateButtonWidget(
                      languageCode: _targetLanguage['code']!,
                      languageName: _targetLanguage['name']!,
                      flag: _targetLanguage['flag']!,
                      onTap: () => _showLanguagePicker(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Nút dịch ngôn ngữ
              GestureDetector(
                onTap: _isTranslating ? null : _translateText,
                child: Container(
                  height: 65,
                  decoration: BoxDecoration(
                    color: _isTranslating ? Colors.grey : Color(0xFFFFAD35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: _isTranslating
                        ? CircularProgressIndicator(color: Colors.black)
                        : Text(
                            'translation.translate_now'.tr(),
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TranslateBoardWidget(
                boardText: 'translation.output_hint'.tr(),
                formerIcon: _isCopied ? Icons.check : Icons.copy,
                latterIcon: Icons.volume_up,
                controller: _outputController,
                readOnly: true,
                onFormerIconTap: _copyToClipboard,
                onLatterIconTap: () {
                  _speak(_outputController.text, _targetLanguage['code']);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
