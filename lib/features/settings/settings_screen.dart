import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/auto_lock_service.dart';
import '../auth/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final autoLockMinutes = ref.watch(autoLockProvider);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.syne(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            children: const [
              TextSpan(
                text: 'Settings',
                style: TextStyle(color: AppColors.purple),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 2,
              ),
            ),
            child: const Icon(Icons.arrow_back, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle(context, 'Appearance'),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: isDark ? 'Enabled' : 'Disabled',
            trailing: Switch(
              value: isDark,
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
              activeTrackColor: AppColors.purple.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.purple;
                }
                return null;
              }),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Security'),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.timer,
            title: 'Auto-Lock',
            subtitle: autoLockMinutes == 0
                ? 'Disabled'
                : '$autoLockMinutes minute${autoLockMinutes > 1 ? 's' : ''}',
            onTap: () => _showAutoLockPicker(context, ref),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.fingerprint,
            title: 'Biometric Auth',
            subtitle: 'Use fingerprint or face to unlock',
            trailing: Switch(
              value: true,
              onChanged: (_) {},
              activeTrackColor: AppColors.purple.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.purple;
                }
                return null;
              }),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Data'),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.backup,
            title: 'Export Passwords',
            subtitle: 'Export to encrypted file',
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.restore,
            title: 'Import Passwords',
            subtitle: 'Import from encrypted file',
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Account'),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.lock_reset,
            title: 'Change Master Password',
            subtitle: 'Update your master password',
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            context,
            icon: Icons.logout,
            title: 'Lock Vault',
            subtitle: 'Lock the app immediately',
            onTap: () => ref.read(authProvider.notifier).lock(),
            iconColor: AppColors.red,
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Vault v1.0.0',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.syne(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.purple).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor ?? AppColors.purple, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }

  void _showAutoLockPicker(BuildContext context, WidgetRef ref) {
    final options = [
      {'value': 0, 'label': 'Disabled'},
      {'value': 1, 'label': '1 minute'},
      {'value': 5, 'label': '5 minutes'},
      {'value': 10, 'label': '10 minutes'},
      {'value': 15, 'label': '15 minutes'},
      {'value': 30, 'label': '30 minutes'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auto-Lock Timer',
                style: GoogleFonts.syne(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final isSelected = ref.read(autoLockProvider) == opt['value'];
                return ListTile(
                  title: Text(opt['label'] as String),
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? AppColors.purple : null,
                  ),
                  onTap: () {
                    ref.read(autoLockProvider.notifier).setAutoLockMinutes(opt['value'] as int);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming soon!'),
        backgroundColor: AppColors.purple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
