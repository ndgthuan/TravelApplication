import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/screen/Account/widgets/button_widget.dart';
import 'package:travel_app/screen/Account/widgets/setting_card_widget.dart';
import 'package:travel_app/screen/Account/widgets/stat_widget.dart';
import 'package:travel_app/screen/Account/widgets/utilities_grid_widget.dart';
import 'package:travel_app/screen/Auth/screens/login_screen.dart';
import 'package:travel_app/screen/Auth/services/auth_service.dart';
import 'package:travel_app/screen/Auth/services/storage_service.dart';
import 'package:travel_app/screen/Auth/services/user_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isDarkMode = true;
  String? _userName;
  String? _userEmail;
  String? _avatarUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load các dữ liệu từ firestore
  Future<void> _loadUserData() async {
    final data = await UserService.getCurrentUserData();
    if (!mounted) return;
    setState(() {
      _userName = data?['name'];
      _userEmail = data?['email'];
      _avatarUrl = data?['avatarUrl'];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild mỗi khi đổi ngôn ngữ
    var _ = context.locale;

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
                  height: 150,
                  decoration: BoxDecoration(color: Color(0xFFFFAD35)),
                ),
                // Icon hình tròn
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFFFAD35)),
                        shape: BoxShape.circle,
                        // Thay gradient bằng image
                        image: _avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        // Giữ gradient làm fallback nếu không có avatar
                        gradient: _avatarUrl == null
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1E1E1E), Color(0xFF1A1A1A)],
                              )
                            : null,
                      ),
                      // Hiển thị icon mặc định nếu không có avatar
                      child: _avatarUrl == null
                          ? Icon(
                              Icons.person,
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
              _isLoading ? 'Loading...' : (_userName ?? 'NoName'),
              style: GoogleFonts.beVietnamPro(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Email của người dùng
            Text(
              _isLoading ? '' : (_userEmail ?? 'No Email'),
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
                    child: StatWidget(
                      title: 'navigation.plan'.tr(),
                      number: 8,
                      icon: Icons.insert_drive_file_sharp,
                    ),
                  ),
                  const SizedBox(width: 5),

                  Expanded(
                    child: StatWidget(
                      title: 'navigation.favourite'.tr(),
                      number: 8,
                      icon: Icons.favorite,
                    ),
                  ),
                  const SizedBox(width: 5),

                  Expanded(
                    child: StatWidget(
                      title: 'account.past_trips'.tr(),
                      number: 8,
                      icon: Icons.check,
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
                  _loadUserData();
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: ActionButton(
                      buttonName: 'account.log_out'.tr(),
                      color: Colors.redAccent,
                      onTap: () async {
                        // Xoá hoàn toàn Credentials
                        await StorageService.clearCredentials();
                        // Đăng xuất Firebase
                        await AuthService().signOut();
                        Navigator.of(
                          // ignore: use_build_context_synchronously
                          context,
                          rootNavigator: true,
                        ).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: ActionButton(
                      buttonName: 'account.switch_account'.tr(),
                      color: Color(0xFFFFAD35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
