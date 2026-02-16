import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TranslateBoardWidget extends StatefulWidget {
  final IconData formerIcon;
  final IconData latterIcon;
  final String boardText;
  final Uint8List? imageBytes;
  final TextEditingController? controller;
  final bool readOnly;
  final VoidCallback? onFormerIconTap;
  final VoidCallback? onLatterIconTap;
  final VoidCallback? onClearTap; // Callback khi tap nút X

  const TranslateBoardWidget({
    super.key,
    required this.boardText,
    required this.formerIcon,
    required this.latterIcon,
    this.controller,
    this.readOnly = false,
    this.onFormerIconTap,
    this.onLatterIconTap,
    this.imageBytes,
    this.onClearTap,
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
            // Hiển thị ảnh nếu có, không thì hiển thị TextFormField
            if (widget.imageBytes != null)
              GestureDetector(
                onTap: _showZoomImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xFF1C1C1D),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      widget.imageBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              )
            else
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
                    borderSide: BorderSide(color: Color(0xFFFF6D00)),
                  ),
                  hintText: widget.boardText,
                  hintStyle: GoogleFonts.beVietnamPro(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
              ),

            // Nút X để xóa ảnh (góc phải trên)
            if (widget.imageBytes != null && widget.onClearTap != null)
              Positioned(
                right: 10,
                top: 10,
                child: GestureDetector(
                  onTap: widget.onClearTap,
                  child: Icon(Icons.close, color: Color(0xFFFF6D00), size: 20),
                ),
              ),

            // Icons - giữ nguyên
            Positioned(
              right: 15,
              bottom: 15,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onFormerIconTap,
                    child: Icon(widget.formerIcon, color: Color(0xFFFF6D00)),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: widget.onLatterIconTap,
                    child: Icon(widget.latterIcon, color: Color(0xFFFF6D00)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  //==========================================================================//
  //                         HELPER METHODS                                   //
  //==========================================================================//
  void _showZoomImage() {
    if (widget.imageBytes == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          // Blur background
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),
          // Dismiss tap
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
          ),
          // Image
          Center(
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.memory(widget.imageBytes!),
            ),
          ),
          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
