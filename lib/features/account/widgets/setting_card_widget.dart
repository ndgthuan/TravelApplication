import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:travel_app/features/account/screens/change_password_screen.dart';
import 'package:travel_app/features/Support/screens/help_support_screen.dart';
import 'package:travel_app/features/account/screens/information_screen.dart';
import 'package:travel_app/features/account/screens/language_screen.dart';
import 'setting_row_widget.dart';
import 'simple_divider_widget.dart';
import 'dark_mode_switch_widget.dart';

class SettingCardWidget extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool)? onDarkModeChanged;
  final VoidCallback? onDataUpdated;
  const SettingCardWidget({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    this.onDataUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Thông tin cá nhân
              SettingRowWidget(
                optionText: 'account.personal_information'.tr(),
                optionIcon: Icons.person_outline,
                onTap: () async {
                  final result =
                      await Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => InformationScreen(),
                        ),
                      );

                  // Gọi callback
                  if (result == true && onDataUpdated != null) {
                    onDataUpdated!();
                  }
                },
              ),
              const SizedBox(height: 20),
              // Thannh ngang
              SimpleDividerWidget(),
              const SizedBox(height: 20),
              SettingRowWidget(
                optionText: 'account.change_password'.tr(),
                optionIcon: Icons.lock_outline,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Thannh ngang
              SimpleDividerWidget(),
              const SizedBox(height: 20),
              SettingRowWidget(
                optionText: 'account.language'.tr(),
                optionIcon: Icons.language_outlined,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(builder: (context) => LanguageScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Thannh ngang
              SimpleDividerWidget(),
              const SizedBox(height: 15),
              DarkModeWidget(
                isDarkMode: isDarkMode,
                onChanged: onDarkModeChanged,
              ),

              const SizedBox(height: 15),
              // Thannh ngang
              SimpleDividerWidget(),
              const SizedBox(height: 20),
              SettingRowWidget(
                optionText: 'account.help_support'.tr(),
                optionIcon: Icons.help_outline,
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => HelpSupportScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
