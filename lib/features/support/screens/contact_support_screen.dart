import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/Support/viewmodels/contact_support_view_model.dart';
import 'package:travel_app/shared/widgets/app_button_widget.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  // Controllers
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // Reset state khi vào trang
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactSupportViewModel>().reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ContactSupportViewModel>();
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
            const SizedBox(height: 20),
            // Hộp subject
            AppTextFieldWidget(
              labelText: 'account.subject'.tr(),
              hintText: 'account.subject_hint'.tr(),
              controller: _subjectController,
              maxLines: 3,
              showLabel: true,
            ),

            const SizedBox(height: 20),
            // Hộp nhập message
            AppTextFieldWidget(
              labelText: 'account.message'.tr(),
              hintText: 'account.message_hint'.tr(),
              controller: _messageController,
              maxLines: 8,
              showLabel: true,
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: viewModel.isSending
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFAD35),
                      ),
                    )
                  : Column(
                      children: [
                        if (viewModel.errorMessage != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              viewModel.errorMessage!.tr(),
                              style: GoogleFonts.beVietnamPro(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        AppButtonWidget(
                          buttonText: 'account.send_report'.tr(),
                          onTap: () async {
                            final viewModel = context
                                .read<ContactSupportViewModel>();
                            final success = await viewModel.sendSupportEmail(
                              subject: _subjectController.text,
                              message: _messageController.text,
                            );
                            if (success && mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('account.send_success'.tr()),
                                  backgroundColor: Color(0xFFFFAD35),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            }
                          },
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
