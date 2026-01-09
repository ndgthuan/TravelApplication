import 'package:flutter/material.dart';
import 'option_widget.dart';
import 'divider_widget.dart';
import 'dark_mode_widget.dart';

class SettingCardWidget extends StatelessWidget {
  final bool isDarkMode;
  final Function(bool)? onDarkModeChanged;
  const SettingCardWidget({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
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
              OptionWidget(
                optionText: 'Personal Information',
                optionIcon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              // Thannh ngang
              DividerWidget(),
              const SizedBox(height: 20),
              OptionWidget(
                optionText: 'Change Password',
                optionIcon: Icons.lock_outline,
              ),
              const SizedBox(height: 20),
              // Thannh ngang
              DividerWidget(),
              const SizedBox(height: 20),
              OptionWidget(
                optionText: 'Language',
                optionIcon: Icons.language_outlined,
              ),
              const SizedBox(height: 20),
              // Thannh ngang
              DividerWidget(),
              const SizedBox(height: 15),
              DarkModeWidget(
                isDarkMode: isDarkMode,
                onChanged: onDarkModeChanged,
              ),

              const SizedBox(height: 15),
              // Thannh ngang
              DividerWidget(),
              const SizedBox(height: 20),
              OptionWidget(
                optionText: 'Help & Support',
                optionIcon: Icons.help_outline,
              ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}
