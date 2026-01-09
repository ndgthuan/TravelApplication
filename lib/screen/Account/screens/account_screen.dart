import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_app/screen/Account/widgets/button_widget.dart';
import 'package:travel_app/screen/Account/widgets/setting_card_widget.dart';
import 'package:travel_app/screen/Account/widgets/stat_widget.dart';
import 'package:travel_app/screen/Account/widgets/utilities_grid_widget.dart';
import 'package:travel_app/screen/Auth/screens/login_screen.dart';
import 'package:travel_app/screen/Auth/services/auth_service.dart';
import 'package:travel_app/screen/Auth/services/storage_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isDarkMode = true;
  @override
  Widget build(BuildContext context) {
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1E1E1E), // Màu sáng hơn
                            Color(0xFF1A1A1A), // Màu tối
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Tên người dùng
            Text(
              'Nguyễn Dương Gia Thuận',
              style: GoogleFonts.beVietnamPro(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Email của người dùng
            Text(
              'giathuannguyenduong5000@gmail.com',
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
                      title: 'My Plans',
                      number: 8,
                      icon: Icons.insert_drive_file_sharp,
                    ),
                  ),
                  const SizedBox(width: 5),

                  Expanded(
                    child: StatWidget(
                      title: 'Favourites',
                      number: 8,
                      icon: Icons.favorite,
                    ),
                  ),
                  const SizedBox(width: 5),

                  Expanded(
                    child: StatWidget(
                      title: 'Past Trips',
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
                  'Utilities',
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
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: ActionButton(
                      buttonName: 'Logout',
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
                      buttonName: 'Switch Account',
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
