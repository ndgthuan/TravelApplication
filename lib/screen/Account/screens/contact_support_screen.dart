import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/shared/widgets/action_button_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  // Controllers
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // State
  bool _isSending = false;
  String? _errorMessage;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Hàm gửi email qua EmailJS
  Future<void> _sendEmail() async {
    if (_subjectController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'account.fill_all_fields'.tr());
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSending = true;
    });

    // Lấy thông tin user hiện tại
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'App User';
    final userEmail = user?.email ?? 'no-reply@app.com';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['PRIVATE_KEY']}',
        },
        body: json.encode({
          'service_id': dotenv.env['SERVICE_ID'],
          'template_id': dotenv.env['TEMPLATE_ID'],
          'user_id': dotenv.env['PUBLIC_KEY'],
          'accessToken': dotenv.env['PRIVATE_KEY'],
          'template_params': {
            'title': _subjectController.text,
            'message': _messageController.text,
            'name': userName,
            'email': userEmail,
          },
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('account.send_success'.tr()),
            backgroundColor: Color(0xFFFFAD35),
            duration: Duration(seconds: 1),
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      print('EmailJS Error: $e'); // Debug
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('account.send_error'.tr()),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1C1D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'account.contact_support'.tr(),
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
                    'account.subject'.tr(),
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),

                    child: TextFormField(
                      controller: _subjectController,
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
                        hintText: 'account.subject_hint'.tr(),
                        hintStyle: GoogleFonts.beVietnamPro(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                        fillColor: Color(0xFF1C1C1D),
                        filled: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'account.message'.tr(),
                    style: GoogleFonts.beVietnamPro(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      controller: _messageController,
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
                        hintText: 'account.message_hint'.tr(),
                        hintStyle: GoogleFonts.beVietnamPro(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                        fillColor: Color(0xFF1C1C1D),
                        filled: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _isSending
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFAD35),
                      ),
                    )
                  : Column(
                      children: [
                        if (_errorMessage != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ActionButtonWidget(
                          buttonText: 'account.send_report'.tr(),
                          onTap: _sendEmail,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
