import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TranslateBoardWidget extends StatefulWidget {
  final IconData formerIcon;
  final IconData latterIcon;
  final String boardText;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onFormerIconTap;
  final VoidCallback? onLatterIconTap;
  const TranslateBoardWidget({
    super.key,
    required this.boardText,
    required this.formerIcon,
    required this.latterIcon,
    this.controller,
    this.readOnly = false,
    this.onFormerIconTap,
    this.onLatterIconTap,
  });

  @override
  State<TranslateBoardWidget> createState() => _TranslateBoardWidgetState();
}

class _TranslateBoardWidgetState extends State<TranslateBoardWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            TextFormField(
              controller: widget.controller,
              readOnly: widget.readOnly,
              style: GoogleFonts.beVietnamPro(
                color: Colors.white,
                fontSize: 16,
              ),
              maxLines: 10,
              decoration: InputDecoration(
                fillColor: Color(0xFF1C1C1D),
                filled: true,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Color(0xFFFFAD35)),
                ),
                hintText: widget.boardText,
                hintStyle: GoogleFonts.beVietnamPro(
                  color: Colors.grey[600],
                  fontSize: 18,
                ),
              ),
            ),

            Positioned(
              right: 15,
              bottom: 15,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onFormerIconTap,
                    child: Icon(widget.formerIcon, color: Color(0xFFFFAD35)),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: widget.onLatterIconTap,
                    child: Icon(widget.latterIcon, color: Color(0xFFFFAD35)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
