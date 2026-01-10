import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordFieldWidget extends StatefulWidget {
  final FocusNode? focusNode;
  final bool isShowing;
  final String labelText;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged; // Thêm callback
  const PasswordFieldWidget({
    super.key,
    required this.isShowing,
    required this.labelText,
    required this.prefixIcon,
    required this.controller,
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
      padding: EdgeInsets.only(left: 20, right: 20),
      child: TextFormField(
        // Tạo phương thức đăng ký
        validator: widget.validator,
        controller: widget.controller,

        // Ẩn hiện thanh độ password strength
        focusNode: widget.focusNode,
        onChanged: widget.onChanged, // Thêm dòng này
        style: GoogleFonts.beVietnamPro(color: Colors.white),
        obscureText: isShowing,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFFFFAD33), width: 1.5),
          ),
          labelText: widget.labelText,
          labelStyle: GoogleFonts.beVietnamPro(
            color: Colors.grey[600],
            fontSize: 18,
          ),
          fillColor: Color(0xFF1C1C1D),
          filled: true,

          // Tạo icon nằm ở trước hộp nhập
          prefixIcon: Icon(widget.prefixIcon, color: Colors.grey[600]),

          // Tạo icon con mắt ở sau hộp nhập
          suffixIcon: IconButton(
            // Nếu ấn vào thì chuyển sang icon còn lại
            onPressed: () => setState(() {
              isShowing = !isShowing;
            }),
            icon: Icon(
              isShowing ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
