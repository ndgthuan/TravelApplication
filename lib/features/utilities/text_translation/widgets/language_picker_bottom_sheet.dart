import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../viewmodels/text_translation_view_model.dart';
import '../../../../shared/widgets/app_text_field_widget.dart';

class LanguagePickerBottomSheet extends StatefulWidget {
  final bool isSource;

  const LanguagePickerBottomSheet({super.key, required this.isSource});

  @override
  State<LanguagePickerBottomSheet> createState() =>
      _LanguagePickerBottomSheetState();
}

class _LanguagePickerBottomSheetState extends State<LanguagePickerBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load languages khi bottom sheet mở
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<TextTranslationViewModel>();
      viewModel.setSearchQuery(''); // Reset search
      viewModel.loadLanguages(); // Load ngôn ngữ search
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TextTranslationViewModel>(
      builder: (context, viewModel, child) {
        // Filter variables from ViewModel
        final filteredLanguages = viewModel.filteredLanguages;

        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.isSource
                    ? 'translation.choose_source'.tr()
                    : 'translation.choose_target'.tr(),
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 15),

              // Search Bar
              AppTextFieldWidget(
                controller: _searchController,
                hintText: 'Search language...',
                prefixIcon: CupertinoIcons.search,
                horizontalPadding: 0,
                onChanged: (value) {
                  viewModel.setSearchQuery(value);
                },
              ),

              SizedBox(height: 15),
              Flexible(
                child: viewModel.isLoadingLanguages
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFAD35),
                        ),
                      )
                    : filteredLanguages.isEmpty
                    ? Center(
                        child: Text(
                          'No language found',
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredLanguages.length,
                        itemBuilder: (context, index) {
                          final lang = filteredLanguages[index];
                          final isSelected = widget.isSource
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
                                    CupertinoIcons.checkmark_circle,
                                    color: Color(0xFFFFAD35),
                                  )
                                : null,
                            onTap: () {
                              viewModel.selectLanguage(lang, widget.isSource);
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
