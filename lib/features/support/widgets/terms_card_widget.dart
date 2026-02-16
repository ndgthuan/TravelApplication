import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../account/widgets/simple_divider_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsCardWidget extends StatefulWidget {
  final String titleText;
  final String paragraphText;
  final VoidCallback? onTap;
  const TermsCardWidget({
    super.key,
    required this.titleText,
    required this.paragraphText,
    this.onTap,
  });

  @override
  State<TermsCardWidget> createState() => _TermsCardWidgetState();
}

class _TermsCardWidgetState extends State<TermsCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1C1C1D),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề
              Text(
                widget.titleText,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 15),

              SimpleDividerWidget(),

              const SizedBox(height: 15),

              // Nội dung
              Text(
                widget.paragraphText,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontFamily: 'ProductSans',
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: widget.onTap,
                child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(15),
                    ),

                    // Tên của hoạt động
                    child: Center(
                      child: Text(
                        'account.read_full_document'.tr(),
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
