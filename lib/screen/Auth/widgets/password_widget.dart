import 'package:flutter/material.dart';

Color getPasswordStrength(int strength) {
  if (strength <= 3) return Colors.grey.shade700;
  if (strength <= 5) return Colors.grey.shade500;
  if (strength <= 7) return Colors.grey.shade300;
  return Colors.white;
}

String getStrengthText(int strength) {
  if (strength <= 3) return "Weak";
  if (strength <= 5) return "Medium";
  if (strength <= 7) return "Good";
  return "Excellent";
}
