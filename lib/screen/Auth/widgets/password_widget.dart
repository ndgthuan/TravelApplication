import 'package:flutter/material.dart';

Color getPasswordStrength(int strength) {
  if (strength <= 3) return Colors.redAccent;
  if (strength <= 5) return Colors.orange.shade800;
  if (strength <= 6) return Colors.yellow;
  return Color(0xFFFFAD33);
}

String getStrengthText(int strength) {
  if (strength <= 3) return "Weak";
  if (strength <= 5) return "Medium";
  if (strength <= 6) return "Good";
  return "Excellent";
}
