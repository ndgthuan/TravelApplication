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
    strength += 1;
  }

  return strength;
}
