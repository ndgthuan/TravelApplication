import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

Color getPasswordStrength(int strength) {
  if (strength <= 3) return Colors.redAccent;
  if (strength <= 5) return Colors.orange.shade800;
  if (strength <= 6) return Colors.yellow;
  return Color(0xFFFFAD33);
}

String getStrengthText(int strength) {
  if (strength <= 3) return "auth.weak".tr();
  if (strength <= 5) return "auth.medium".tr();
  if (strength <= 6) return "auth.good".tr();
  return "auth.excellent".tr();
}
