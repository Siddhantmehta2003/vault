import 'dart:math';

class PasswordGenerator {
  static const String _lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String _uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _numbers = '0123456789';
  static const String _symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

  static String generate({
    int length = 16,
    bool includeLowercase = true,
    bool includeUppercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    String chars = '';
    if (includeLowercase) chars += _lowercase;
    if (includeUppercase) chars += _uppercase;
    if (includeNumbers) chars += _numbers;
    if (includeSymbols) chars += _symbols;

    if (chars.isEmpty) chars = _lowercase + _uppercase + _numbers;

    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static PasswordStrength calculateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;
    if (password.length < 6) return PasswordStrength.weak;

    int score = 0;

    // Length score
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;

    // Character variety score
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]'))) score++;

    // No common patterns
    if (!_hasCommonPatterns(password)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    if (score <= 6) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  static bool _hasCommonPatterns(String password) {
    final commonPatterns = [
      '123456', 'password', 'qwerty', 'abc123', '111111',
      '123123', 'admin', 'letmein', 'welcome', 'monkey',
    ];
    final lowerPassword = password.toLowerCase();
    return commonPatterns.any((pattern) => lowerPassword.contains(pattern));
  }
}

enum PasswordStrength {
  none,
  weak,
  fair,
  good,
  strong;

  String get label {
    switch (this) {
      case PasswordStrength.none: return '';
      case PasswordStrength.weak: return 'Weak';
      case PasswordStrength.fair: return 'Fair';
      case PasswordStrength.good: return 'Good';
      case PasswordStrength.strong: return 'Strong';
    }
  }

  double get value {
    switch (this) {
      case PasswordStrength.none: return 0.0;
      case PasswordStrength.weak: return 0.25;
      case PasswordStrength.fair: return 0.5;
      case PasswordStrength.good: return 0.75;
      case PasswordStrength.strong: return 1.0;
    }
  }
}
