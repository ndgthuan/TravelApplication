import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_flags/country_flags.dart';

class LanguageCardWidget extends StatefulWidget {
  final bool isSelected;
  final VoidCallback? onTap;
  final String countryCode;
  final String languageChosenText;
  final String englishText;
  const LanguageCardWidget({
    super.key,
    required this.countryCode,
    required this.languageChosenText,
    required this.englishText,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<LanguageCardWidget> createState() => _LanguageCardWidgetState();
}

class _LanguageCardWidgetState extends State<LanguageCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF1C1C1D),
              border: widget.isSelected
                  ? Border.all(color: Color(0xFFFFAD35), width: 2)
                  : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Lá cờ
                      CountryFlag.fromCountryCode(
                        widget.countryCode,
                        height: 45,
                        width: 65,
                        shape: RoundedRectangle(8),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tên của tiếng được chọn của ngôn ngữ đó
                          Text(
                            widget.languageChosenText,
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),

                          Text(
                            widget.englishText,
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Icon hiện khi được chọn
                  if (widget.isSelected)
                    Icon(CupertinoIcons.checkmark_circle, color: Colors.green, size: 28),
                ],
              ),
            ),
        ),
      ),
    );
  }
}
