import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/account/viewmodels/account_view_model.dart';
import 'package:travel_app/features/explore/viewmodels/explore_view_model.dart';
import 'package:travel_app/features/plan/viewmodels/plan_view_model.dart';
import 'package:travel_app/features/account/widgets/setting_card_widget.dart';
import 'package:travel_app/features/account/widgets/account_stat_card_widget.dart';
import 'package:travel_app/features/account/widgets/utilities_grid_widget.dart';
import 'package:travel_app/features/auth/screens/login_screen.dart';
import 'package:travel_app/shared/widgets/app_button_widget.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    // Gọi ViewModel load data từ firestore sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountViewModel>().loadUserData();
      context.read<ExploreViewModel>().refreshSavedDestinations();
    });
  }

  bool _isValidImageUrl(String? url) => url != null && url.trim().isNotEmpty;

  // Tạo method thay đổi nền
  Future<void> _changeBackgroundImage() async {
    final viewModel = context.read<AccountViewModel>();
    // Mở thư viện gallery
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    // Kiểm tra nếu user không chọn ảnh
    if (pickedFile == null) return;

    // Chuyển XFile thành File và upload qua ViewModel
    final File imageFile = File(pickedFile.path);
    await viewModel.uploadBackgroundImage(imageFile);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild mỗi khi đổi ngôn ngữ
    var _ = context.locale;
    final viewModel = context.watch<AccountViewModel>();
    final exploreViewModel = context.watch<ExploreViewModel>();
    final planViewModel = context.watch<PlanViewModel>();
    // Build
    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // Background đằng sau hình tròn
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    // Màu nền khi chưa có ảnh
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFFF6D00), width: 1),
                    ),
                    color: Color(0xFF1C1C1D),
                    image: _isValidImageUrl(viewModel.backgroundUrl)
                        ? DecorationImage(
                            image: NetworkImage(viewModel.backgroundUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                // Nút đổi hình nền
                Positioned(
                  right: 5,
                  top: 165,
                  child: GestureDetector(
                    onTap: _changeBackgroundImage,
                    child: Icon(Icons.edit, color: Color(0xFFFF6D00)),
                  ),
                ),
                // Avatar
                Padding(
                  padding: const EdgeInsets.only(top: 115),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFFF6D00)),
                        shape: BoxShape.circle,
                        // Thay gradient bằng image
                        image: _isValidImageUrl(viewModel.avatarUrl)
                            ? DecorationImage(
                                image: NetworkImage(viewModel.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        // Giữ gradient làm fallback nếu không có avatar
                        gradient: !_isValidImageUrl(viewModel.avatarUrl)
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1E1E1E), Color(0xFF1A1A1A)],
                              )
                            : null,
                      ),
                      // Hiển thị icon mặc định nếu không có avatar
                      child: !_isValidImageUrl(viewModel.avatarUrl)
                          ? Icon(
                              CupertinoIcons.person,
                              color: Colors.grey[600],
                              size: 60,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Tên người dùng
            Text(
              viewModel.isLoading
                  ? 'general.loading'.tr()
                  : (viewModel.userName ?? 'account.no_name'.tr()),
              style: GoogleFonts.beVietnamPro(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Email của người dùng
            Text(
              viewModel.isLoading
                  ? ''
                  : (viewModel.userEmail ?? 'account.no_email'.tr()),
              style: GoogleFonts.beVietnamPro(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Các thẻ hoạt động
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: AccountStatCardWidget(
                      title: 'navigation.plan'.tr(),
                      number:
                          planViewModel.ongoingPlans.length +
                          planViewModel.upcomingPlans.length,
                      icon: CupertinoIcons.doc_fill,
                    ),
                  ),
                  const SizedBox(width: 5),

                  Expanded(
                    child: AccountStatCardWidget(
                      title: 'account.wishlist'.tr(),
                      number: exploreViewModel.savedIds.length,
                      icon: CupertinoIcons.heart_fill,
                    ),
                  ),
                  const SizedBox(width: 5),

                  Expanded(
                    child: AccountStatCardWidget(
                      title: 'account.past_trips'.tr(),
                      number: 0,
                      icon: CupertinoIcons.checkmark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'account.utilities'.tr(),
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: UtilitiesGridWidget(),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: SettingCardWidget(
                isDarkMode: isDarkMode,
                onDarkModeChanged: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                },
                onDataUpdated: () {
                  viewModel.loadUserData();
                },
              ),
            ),
            const SizedBox(height: 20),
            AppButtonWidget(
              buttonText: 'account.log_out'.tr(),
              style: AppButtonStyle.outlined,
              outlineColor: Colors.redAccent,
              onTap: () async {
                await viewModel.signOut();
                Navigator.of(
                  // ignore: use_build_context_synchronously
                  context,
                  rootNavigator: true,
                ).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
