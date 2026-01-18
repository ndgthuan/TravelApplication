import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordFieldWidget extends StatefulWidget {
  // Text
  final String? labelText;
  final String? hintText;
  final String? titleText;
  final bool showTitle;

  // Behavior
  final FocusNode? focusNode;
  final bool isShowing;

  final IconData prefixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged; // Thêm callback
  const PasswordFieldWidget({
    super.key,
    required this.isShowing,
    required this.prefixIcon,
    required this.controller,
    this.labelText,
    this.titleText,
    this.hintText,
    this.showTitle = false,
    this.validator,
    this.onChanged,
    this.focusNode,
  });

  @override
  State<PasswordFieldWidget> createState() => _PasswordFieldWidgetState();
}

class _PasswordFieldWidgetState extends State<PasswordFieldWidget> {
  late bool isShowing;
  @override
  void initState() {
    super.initState();
    isShowing = widget.isShowing;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title phía trên (nếu showTitle = true)
          if (widget.showTitle && widget.titleText != null) ...[
            Text(
              widget.titleText!,
              style: GoogleFonts.beVietnamPro(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
          ],
          // TextFormField chính
          TextFormField(
            validator: widget.validator,
            controller: widget.controller,
            focusNode: widget.focusNode,
            onChanged: widget.onChanged,
            style: GoogleFonts.beVietnamPro(color: Colors.white),
            obscureText: isShowing,
            cursorColor: const Color(0xFFFFAD35),
            decoration: InputDecoration(
              // Label hoặc hint
              labelText: widget.showTitle ? null : widget.labelText,
              labelStyle: GoogleFonts.beVietnamPro(
                color: Colors.grey[600],
                fontSize: 18,
              ),
              hintText: widget.hintText,
              hintStyle: GoogleFonts.beVietnamPro(
                color: Colors.grey[600],
                fontSize: 18,
              ),
              // Border
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFFFAD33),
                  width: 1.5,
                ),
              ),
              // Fill
              fillColor: const Color(0xFF1C1C1D),
              filled: true,
              // Icons
              prefixIcon: Icon(widget.prefixIcon, color: Colors.grey[600]),
              suffixIcon: IconButton(
                onPressed: () => setState(() {
                  isShowing = !isShowing;
                }),
                icon: Icon(
                  isShowing ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
