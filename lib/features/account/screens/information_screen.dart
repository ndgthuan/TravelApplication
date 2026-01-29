import 'package:provider/provider.dart';
import 'package:travel_app/features/account/viewmodels/information_view_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app/shared/utils/date_input_formatter.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';
import 'dart:io';

import 'package:travel_app/shared/widgets/app_button_widget.dart';
import 'package:travel_app/shared/widgets/app_text_field_widget.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool isClick = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // Gọi phương thức gán
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<InformationViewModel>();
      await viewModel.loadUserData();
      // Cập nhật controllers từ viewModel
      nameController.text = viewModel.name;
      emailController.text = viewModel.email;
      phoneController.text = viewModel.phone;
      dobController.text = viewModel.dob;
      addressController.text = viewModel.address;
    });
  }

  bool _isValidImageUrl(String? url) => url != null && url.trim().isNotEmpty;

  // Tạo method chọn ảnh từ gallery
  Future<void> _pickImage() async {
    final viewModel = context.read<InformationViewModel>();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _selectedImage = File(image.path));
      await viewModel.uploadAvatar(File(image.path));
    }
  }

  // Tạo format cho ngày tháng năm
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InformationViewModel>();
    // Rebuild mỗi khi đổi ngôn ngữ
    var _ = context.locale;
    return Scaffold(
      appBar: AppBarWidget(title: 'account.personal_information'.tr()),
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
                            : _isValidImageUrl(viewModel.avatarUrl)
                            ? DecorationImage(
                                image: NetworkImage(viewModel.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        // Giữ gradient làm fallback nếu không có avatar
                        gradient:
                            _selectedImage == null &&
                                !_isValidImageUrl(viewModel.avatarUrl)
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1E1E1E), Color(0xFF1A1A1A)],
                              )
                            : null,
                      ),
                      // Hiển thị icon mặc định nếu không có avatar
                      child:
                          _selectedImage == null &&
                              !_isValidImageUrl(viewModel.avatarUrl)
                          ? Icon(
                              CupertinoIcons.person,
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
                              CupertinoIcons.pen,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Loading indicator để đảm bảo sẽ lưu avatar
                    if (viewModel.isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFAD35),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            AppTextFieldWidget(
              prefixIcon: CupertinoIcons.person,
              labelText: 'account.full_name'.tr(),
              hintText: 'account.enter_name'.tr(),
              controller: nameController,
              showLabel: true,
            ),
            const SizedBox(height: 15),

            AppTextFieldWidget(
              prefixIcon: CupertinoIcons.mail,
              labelText: 'auth.email'.tr(),
              hintText: 'account.enter_email'.tr(),
              controller: emailController,
              showLabel: true,
              readOnly: true,
            ),
            const SizedBox(height: 15),

            AppTextFieldWidget(
              prefixIcon: CupertinoIcons.phone,
              labelText: 'account.phone_number'.tr(),
              hintText: 'account.enter_phone'.tr(),
              controller: phoneController,
              showLabel: true,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                LengthLimitingTextInputFormatter(15),
              ],
            ),
            const SizedBox(height: 15),

            AppTextFieldWidget(
              prefixIcon: CupertinoIcons.calendar,
              labelText: 'account.date_of_birth'.tr(),
              hintText: "DD/MM/YYYY",
              controller: dobController,
              showLabel: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(8),
                DateInputFormatter(),
              ],
              validator: (value) {
                if (value != null && value.length == 10) {
                  final parts = value.split('/');
                  final day = int.tryParse(parts[0]) ?? 0;
                  final month = int.tryParse(parts[1]) ?? 0;
                  if (day > 31 || month > 12) {
                    return 'account.invalid_date'.tr();
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 15),

            AppTextFieldWidget(
              prefixIcon: CupertinoIcons.pin,
              labelText: 'account.address'.tr(),
              hintText: 'account.enter_address'.tr(),
              controller: addressController,
              showLabel: true,
            ),
            const SizedBox(height: 30),

            // Save Button
            AppButtonWidget(
              buttonText: "account.save_changes".tr(),
              onTap: () async {
                final viewModel = context.read<InformationViewModel>();
                final success = await viewModel.saveUserData(
                  name: nameController.text,
                  phone: phoneController.text,
                  dob: dobController.text,
                  address: addressController.text,
                );
                // Handle Save Logic
                // ignore: use_build_context_synchronously
                if (success) Navigator.pop(context, true);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
