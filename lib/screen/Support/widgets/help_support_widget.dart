import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpSupportWidget extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final String taskName;
  const HelpSupportWidget({
    super.key,
    required this.icon,
    required this.taskName,
    this.onTap,
  });

  @override
  State<HelpSupportWidget> createState() => _HelpSupportWidgetState();
}

class _HelpSupportWidgetState extends State<HelpSupportWidget> {
  bool isClick = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: GestureDetector(
        onTapDown: (_) => setState(() => isClick = true),
        onTapUp: (_) => setState(() => isClick = false),
        onTapCancel: () => setState(() => isClick = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: isClick ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Color(0xFF1C1C1D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon của hỗ trợ
                        Icon(widget.icon, color: Color(0xFFFFAD35), size: 30),
                        const SizedBox(width: 10),
                        // Tiêu đề của hỗ trợ
                        Expanded(
                          child: Text(
                            widget.taskName,
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Icon mũi tên
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
