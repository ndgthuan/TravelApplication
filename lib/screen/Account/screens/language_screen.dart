import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/screen/Account/widgets/language_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // Biến state để lưu ngôn ngữ
  String _selectedLanguage = 'en';
  bool isClick = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    // Lấy ngôn ngữ hiện tại của app
    _selectedLanguage = context.locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'account.language'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                LanguageCardWidget(
                  countryCode: 'US',
                  languageChosenText: 'English',
                  englishText: 'English',
                  isSelected: _selectedLanguage == 'en',
                  onTap: () {
                    setState(() => _selectedLanguage = 'en');
                    context.setLocale(Locale('en'));
                  },
                ),
                LanguageCardWidget(
                  countryCode: 'VN',
                  languageChosenText: 'Tiếng Việt',
                  englishText: 'Vietnamese',
                  isSelected: _selectedLanguage == 'vi',
                  onTap: () {
                    setState(() => _selectedLanguage = 'vi');
                    context.setLocale(Locale('vi'));
                  },
                ),
                LanguageCardWidget(
                  countryCode: 'CN',
                  languageChosenText: '中文',
                  englishText: 'Chinese',
                  isSelected: _selectedLanguage == 'zh',
                  onTap: () {
                    setState(() => _selectedLanguage = 'zh');
                    context.setLocale(Locale('zh'));
                  },
                ),
                LanguageCardWidget(
                  countryCode: 'JP',
                  languageChosenText: '日本語',
                  englishText: 'Japanese',
                  isSelected: _selectedLanguage == 'ja',
                  onTap: () {
                    setState(() => _selectedLanguage = 'ja');
                    context.setLocale(Locale('ja'));
                  },
                ),
                LanguageCardWidget(
                  countryCode: 'KR',
                  languageChosenText: '한국어',
                  englishText: 'Korean',
                  isSelected: _selectedLanguage == 'ko',
                  onTap: () {
                    setState(() => _selectedLanguage = 'ko');
                    context.setLocale(Locale('ko'));
                  },
                ),
                LanguageCardWidget(
                  countryCode: 'FR',
                  languageChosenText: 'Français',
                  englishText: 'French',
                  isSelected: _selectedLanguage == 'fr',
                  onTap: () {
                    setState(() => _selectedLanguage = 'fr');
                    context.setLocale(Locale('fr'));
                  },
                ),
                LanguageCardWidget(
                  countryCode: 'DE',
                  languageChosenText: 'Deutsch',
                  englishText: 'German',
                  isSelected: _selectedLanguage == 'de',
                  onTap: () {
                    setState(() => _selectedLanguage = 'de');
                    context.setLocale(Locale('de'));
                  },
                ),
                LanguageCardWidget(
                  countryCode: 'RU',
                  languageChosenText: 'Русский',
                  englishText: 'Russian',
                  isSelected: _selectedLanguage == 'ru',
                  onTap: () {
                    setState(() => _selectedLanguage = 'ru');
                    context.setLocale(Locale('ru'));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
