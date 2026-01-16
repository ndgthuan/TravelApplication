import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserGuideWidget extends StatefulWidget {
  final String titleText;
  final String contentText;
  const UserGuideWidget({
    super.key,
    required this.titleText,
    required this.contentText,
  });

  @override
  State<UserGuideWidget> createState() => _UserGuideWidgetState();
}

class _UserGuideWidgetState extends State<UserGuideWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Color(0xFF1C1C1D),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            // Header với tiêu đề và mũi tên
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tên tiêu đề
                    Expanded(
                      child: Text(
                        widget.titleText,
                        style: GoogleFonts.beVietnamPro(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),

                    // Icon mũi tên xoay
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: _isExpanded
                            ? Color(0xFFFFAD35)
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nội dung mở rộng
            AnimatedCrossFade(
              firstChild: SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                child: Text(
                  widget.contentText,
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.grey[400],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
