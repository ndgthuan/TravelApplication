import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

int checkPasswordStrength(String password) {
  int strength = 0;
  if (password.length >= 16) {
    strength += 5;
  } else if (password.length >= 12) {
    strength += 4;
  } else if (password.length >= 8) {
    strength += 3;
  } else if (password.length >= 6) {
    strength += 2;
  } else if (password.isNotEmpty) {
    strength += 1;
  } else {
    strength += 0;
  }

  // Character type score
  if (RegExp(r'[a-z]').hasMatch(password)) {
    strength += 1;
  }
  if (RegExp(r'[A-Z]').hasMatch(password)) {
    strength += 1;
  }
  if (RegExp(r'[0-9]').hasMatch(password)) {
    strength += 1;
  }
  if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
    strength += 2;
  }

  return strength;
}

// Trả về màu dưa trên độ mạnh của password
Color getPasswordStrength(int strength) {
  if (strength <= 3) return Colors.redAccent;
  if (strength <= 5) return Colors.orange.shade800;
  if (strength <= 6) return Colors.yellow;
  return Color(0xFFFFAD33);
}

// Trả về text dựa trên độ mạnh của password
String getPasswordStrengthText(int strength) {
  if (strength <= 3) return "auth.weak".tr();
  if (strength <= 5) return "auth.medium".tr();
  if (strength <= 6) return "auth.good".tr();
  return "auth.excellent".tr();
}
