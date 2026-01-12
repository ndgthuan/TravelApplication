import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/shared/widgets/action_button_widget.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  bool _isClick = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1C1D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'account.report_problem'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'account.error_type'.tr(),
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      width: double.infinity,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Color(0xFF1C1C1D),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'account.choose_error_type'.tr(),
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.grey[600],
                                fontSize: 18,
                              ),
                            ),

                            // Icon mũi tên
                            Icon(
                              Icons.keyboard_arrow_down_outlined,
                              color: Color(0xFFFFAD35),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'account.describe_problem'.tr(),
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      maxLines: 10,
                      cursorColor: Color(0xFFFFAD35),
                      style: GoogleFonts.beVietnamPro(color: Colors.white),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          gapPadding: 0,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Color(0xFFFFAD33),
                            width: 1.5,
                          ),
                        ),
                        // Tạo icon nằm ở trước hộp nhập
                        hintText: 'account.choose_error_type'.tr(),
                        hintStyle: GoogleFonts.beVietnamPro(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                        fillColor: Color(0xFF1C1C1D),
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Nút kèm hình ảnh
                  GestureDetector(
                    onTapDown: (_) => setState(() => _isClick = true),
                    onTapUp: (_) => setState(() => _isClick = false),
                    onTapCancel: () => setState(() => _isClick = false),
                    child: AnimatedScale(
                      scale: _isClick ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      child: Container(
                        height: 80,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF1C1C1D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon attach
                            Icon(
                              Icons.attach_file_outlined,
                              color: Color(0xFFFFAD35),
                            ),
                            Text(
                              'account.attach_screenshot'.tr(),
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 42.0),
              child: ActionButtonWidget(
                buttonText: 'account.submit_report'.tr(),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
