import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';
import '../viewmodels/text_translation_view_model.dart';
import '../widgets/translate_board_widget.dart';
import '../widgets/translate_button_widget.dart';
import '../widgets/language_picker_bottom_sheet.dart';
import '../../../../shared/widgets/app_button_widget.dart';

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
    // Reset state khi vào lại màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<TextTranslationViewModel>();
      viewModel.reset();
      viewModel.loadLanguages(); // Load danh sách ngôn ngữ và preference
      _inputController.clear();
      _outputController.clear();
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
      appBar: AppBarWidget(title: 'translation.title'.tr()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Input board
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
              child: TranslateBoardWidget(
                boardText: 'translation.input_hint'.tr(),
                imageBytes: viewModel.originalImageBytes,
                formerIcon: CupertinoIcons.photo,
                latterIcon: viewModel.isListening
                    ? CupertinoIcons.mic_off
                    : CupertinoIcons.mic,
                controller: _inputController,
                onFormerIconTap: () => viewModel.pickImageFromGallery(),
                onClearTap: viewModel.originalImageBytes != null
                    ? () => viewModel.clearImage()
                    : null,
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
            ),
            const SizedBox(height: 20),

            // Language selector row
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
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
                    onTap: viewModel.canSwapLanguages
                        ? () => viewModel.swapLanguages()
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(
                        CupertinoIcons.arrow_right_arrow_left,
                        color: viewModel.canSwapLanguages
                            ? Color(0xFFFFAD35)
                            : Colors.grey[600],
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
            ),
            const SizedBox(height: 20),

            // Translate button
            AppButtonWidget(
              buttonText: 'translation.translate_now'.tr(),
              isLoading:
                  viewModel.isTranslating || viewModel.isTranslatingImage,
              onTap: () {
                if (viewModel.originalImageBytes != null) {
                  viewModel.translateImage();
                } else {
                  viewModel.translateText(_inputController.text);
                }
              },
            ),
            const SizedBox(height: 20),

            // Output board
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: TranslateBoardWidget(
                boardText: 'translation.output_hint'.tr(),
                imageBytes: viewModel.translatedImageBytes,
                formerIcon: viewModel.isCopied
                    ? CupertinoIcons.checkmark
                    : Icons.copy,
                latterIcon: CupertinoIcons.speaker_2,
                controller: _outputController,
                readOnly: true,
                onFormerIconTap: () =>
                    viewModel.copyToClipboard(_outputController.text),
                onLatterIconTap: () => viewModel.speak(_outputController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
