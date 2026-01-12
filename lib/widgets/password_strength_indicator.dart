import 'package:flutter/material.dart';
import '../core/services/password_generator.dart';
import '../core/theme/app_theme.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final strength = PasswordGenerator.calculateStrength(password);
    if (strength == PasswordStrength.none) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: strength.value,
                  backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(_getColor(strength)),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              strength.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getColor(strength),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.none: return Colors.transparent;
      case PasswordStrength.weak: return AppColors.red;
      case PasswordStrength.fair: return AppColors.yellow;
      case PasswordStrength.good: return AppColors.blue;
      case PasswordStrength.strong: return AppColors.green;
    }
  }
}
