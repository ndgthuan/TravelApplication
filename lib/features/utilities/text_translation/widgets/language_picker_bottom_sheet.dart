import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../viewmodels/text_translation_view_model.dart';

class LanguagePickerBottomSheet extends StatelessWidget {
  final bool isSource;

  const LanguagePickerBottomSheet({super.key, required this.isSource});

  @override
  Widget build(BuildContext context) {
    return Consumer<TextTranslationViewModel>(
      builder: (context, viewModel, child) {
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
                child: viewModel.isLoadingLanguages
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFAD35),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: viewModel.supportedLanguages.length,
                        itemBuilder: (context, index) {
                          final lang = viewModel.supportedLanguages[index];
                          final isSelected = isSource
                              ? lang['code'] == viewModel.sourceLanguage['code']
                              : lang['code'] ==
                                    viewModel.targetLanguage['code'];
                          return ListTile(
                            leading: Text(
                              lang['flag'] ?? '',
                              style: TextStyle(fontSize: 24),
                            ),
                            title: Text(
                              lang['name'] ?? '',
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
                              viewModel.selectLanguage(lang, isSource);
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
}
