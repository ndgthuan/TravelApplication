import 'package:travel_app/screen/Auth/services/cloudinary_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/screen/Account/widgets/profile_field_widget.dart';
import 'package:travel_app/shared/widgets/action_button_widget.dart';
import 'package:travel_app/screen/Auth/services/user_service.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  String? avatarUrl;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool isClick = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Tạo method chọn ảnh từ gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      // Check mounted sau khi async hoàn thành
      if (!mounted) return;

      // Upload ảnh lên firestore
      final url = await CloudinaryService.uploadImage(File(image.path));
      if (url != null) {
        setState(() {
          avatarUrl = url;
        });

        // Lưu URL vào Firestore
        await UserService.updateUserData({'avatarUrl': url});
      }
    }
  }

  // Load dữ liệu từ Firestore
  Future<void> _loadUserData() async {
    final data = await UserService.getCurrentUserData();
    if (data != null) {
      setState(() {
        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        dobController.text = data['dob'] ?? '';
        addressController.text = data['address'] ?? '';
        emailController.text = data['email'] ?? '';
        avatarUrl = data['avatarUrl'];
      });
    }
  }

  // Tạo format cho ngày tháng năm
  @override
  Widget build(BuildContext context) {
    // Rebuild mỗi khi đổi ngôn ngữ
    var _ = context.locale;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFF1C1C1D),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'account.personal_information'.tr(),
          style: GoogleFonts.beVietnamPro(color: Colors.white),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xFF000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Avatar Section
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Align(
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFFFAD35)),
                        shape: BoxShape.circle,
                        // Thay gradient bằng image
                        image: _selectedImage != null
                            ? DecorationImage(
                                image: FileImage(_selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        // Giữ gradient làm fallback nếu không có avatar
                        gradient: avatarUrl == null
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1E1E1E), Color(0xFF1A1A1A)],
                              )
                            : null,
                      ),
                      // Hiển thị icon mặc định nếu không có avatar
                      child: avatarUrl == null
                          ? Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: 60,
                            )
                          : null,
                    ),

                    // Nút edit hình ảnh
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => isClick = true),
                        onTapUp: (_) => setState(() => isClick = false),
                        onTapCancel: () => setState(() => isClick = false),
                        onTap: _pickImage,
                        child: AnimatedScale(
                          scale: isClick ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeInOut,
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFAD35),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ProfileFieldWidget(
              icon: Icons.person_outline,
              label: 'account.full_name'.tr(),
              hintText: 'Enter your name',
              controller: nameController,
            ),

            ProfileFieldWidget(
              icon: Icons.mail_outline,
              label: 'auth.email'.tr(),
              hintText: 'Enter your email',
              controller: emailController,
              readOnly: true,
            ),

            ProfileFieldWidget(
              icon: Icons.phone_outlined,
              label: 'account.phone_number'.tr(),
              hintText: 'Enter your phone number',
              controller: phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                LengthLimitingTextInputFormatter(15),
              ],
            ),

            ProfileFieldWidget(
              icon: Icons.calendar_month_outlined,
              label: 'account.date_of_birth'.tr(),
              hintText: "DD/MM/YYYY",
              keyboardType: TextInputType.number,
              controller: dobController,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
                _DateInputFormatter(),
              ],
            ),

            ProfileFieldWidget(
              icon: Icons.push_pin_outlined,
              label: 'account.address'.tr(),
              hintText: 'Enter your address',
              controller: addressController,
            ),
            const SizedBox(height: 30),

            // Save Button
            ActionButtonWidget(
              buttonText: "account.save_changes".tr(),
              onTap: () async {
                await UserService.updateUserData({
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'dob': dobController.text,
                  'address': addressController.text,
                });
                // Handle Save Logic
                // ignore: use_build_context_synchronously
                Navigator.pop(context, true);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 1 || i == 3) && i != text.length - 1) {
        buffer.write('/');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
