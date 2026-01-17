import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../viewmodels/text_translation_view_model.dart';
import '../widgets/translate_board_widget.dart';
import '../widgets/translate_button_widget.dart';
import '../widgets/language_picker_bottom_sheet.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  // Controllers
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TextTranslationViewModel>().loadLanguages();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TextTranslationViewModel>();

    // Sync translatedText to output controller
    if (viewModel.translatedText.isNotEmpty &&
        _outputController.text != viewModel.translatedText) {
      _outputController.text = viewModel.translatedText;
    }

    // Show error SnackBar
    if (viewModel.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage.tr()),
            backgroundColor: Colors.red,
          ),
        );
        viewModel.clearError();
      });
    }

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
        backgroundColor: Color(0xFF1C1C1D),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            children: [
              // Input board
              TranslateBoardWidget(
                boardText: 'translation.input_hint'.tr(),
                formerIcon: Icons.camera_alt,
                latterIcon: viewModel.isListening ? Icons.mic_off : Icons.mic,
                controller: _inputController,
                onFormerIconTap: () {}, // TODO: Camera OCR
                onLatterIconTap: () {
                  if (viewModel.isListening) {
                    viewModel.stopListening();
                  } else {
                    viewModel.startListening((text) {
                      _inputController.text = text;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Language selector row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TranslateButtonWidget(
                      languageCode: viewModel.sourceLanguage['code'] ?? '',
                      languageName: viewModel.sourceLanguage['name'] ?? '',
                      flag: viewModel.sourceLanguage['flag'] ?? '',
                      onTap: () => showModalBottomSheet(
                        context: context,
                        backgroundColor: Color(0xFF1C1C1D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) =>
                            LanguagePickerBottomSheet(isSource: true),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => viewModel.swapLanguages(),
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
                      languageCode: viewModel.targetLanguage['code'] ?? '',
                      languageName: viewModel.targetLanguage['name'] ?? '',
                      flag: viewModel.targetLanguage['flag'] ?? '',
                      onTap: () => showModalBottomSheet(
                        context: context,
                        backgroundColor: Color(0xFF1C1C1D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) =>
                            LanguagePickerBottomSheet(isSource: false),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Translate button
              GestureDetector(
                onTap: viewModel.isTranslating
                    ? null
                    : () => viewModel.translateText(_inputController.text),
                child: Container(
                  height: 65,
                  decoration: BoxDecoration(
                    color: viewModel.isTranslating
                        ? Colors.grey
                        : Color(0xFFFFAD35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: viewModel.isTranslating
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

              // Output board
              TranslateBoardWidget(
                boardText: 'translation.output_hint'.tr(),
                formerIcon: viewModel.isCopied ? Icons.check : Icons.copy,
                latterIcon: Icons.volume_up,
                controller: _outputController,
                readOnly: true,
                onFormerIconTap: () =>
                    viewModel.copyToClipboard(_outputController.text),
                onLatterIconTap: () => viewModel.speak(_outputController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
