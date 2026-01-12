import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/services/password_generator.dart';
import '../core/theme/app_theme.dart';
import 'password_strength_indicator.dart';

class PasswordGeneratorDialog extends StatefulWidget {
  const PasswordGeneratorDialog({super.key});

  @override
  State<PasswordGeneratorDialog> createState() => _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  String _generatedPassword = '';
  double _length = 16;
  bool _includeLowercase = true;
  bool _includeUppercase = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    setState(() {
      _generatedPassword = PasswordGenerator.generate(
        length: _length.round(),
        includeLowercase: _includeLowercase,
        includeUppercase: _includeUppercase,
        includeNumbers: _includeNumbers,
        includeSymbols: _includeSymbols,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkBgSecondary : AppColors.lightBgPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_fix_high, color: AppColors.purple),
                ),
                const SizedBox(width: 12),
                Text(
                  'Password Generator',
                  style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Generated Password Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBgPrimary : AppColors.lightBgSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 2,
                ),
              ),
              child: SelectableText(
                _generatedPassword,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),

            PasswordStrengthIndicator(password: _generatedPassword),
            const SizedBox(height: 20),

            // Length Slider
            Row(
              children: [
                Text(
                  'Length: ${_length.round()}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Slider(
                    value: _length,
                    min: 8,
                    max: 32,
                    divisions: 24,
                    activeColor: AppColors.purple,
                    onChanged: (value) {
                      setState(() => _length = value);
                      _generatePassword();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Character Options
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildOptionChip('a-z', _includeLowercase, (v) {
                  setState(() => _includeLowercase = v);
                  _generatePassword();
                }),
                _buildOptionChip('A-Z', _includeUppercase, (v) {
                  setState(() => _includeUppercase = v);
                  _generatePassword();
                }),
                _buildOptionChip('0-9', _includeNumbers, (v) {
                  setState(() => _includeNumbers = v);
                  _generatePassword();
                }),
                _buildOptionChip('!@#', _includeSymbols, (v) {
                  setState(() => _includeSymbols = v);
                  _generatePassword();
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _generatePassword,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Regenerate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.purple,
                      side: const BorderSide(color: AppColors.purple, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _generatedPassword));
                      Navigator.pop(context, _generatedPassword);
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Use Password'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionChip(String label, bool selected, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onChanged,
      selectedColor: AppColors.purple.withValues(alpha: 0.2),
      checkmarkColor: AppColors.purple,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: selected ? AppColors.purple : null,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? AppColors.purple : Colors.grey,
          width: 2,
        ),
      ),
    );
  }
}
