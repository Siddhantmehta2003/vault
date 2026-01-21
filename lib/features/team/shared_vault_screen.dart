import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'models/team_models.dart';
import 'providers/team_provider.dart';
import '../vault/models/password_model.dart';
import '../vaults/password_details_screen.dart';

class SharedVaultScreen extends ConsumerStatefulWidget {
  final SharedVaultModel vault;
  final String teamId;

  const SharedVaultScreen(
      {super.key, required this.vault, required this.teamId});

  @override
  ConsumerState<SharedVaultScreen> createState() => _SharedVaultScreenState();
}

class _SharedVaultScreenState extends ConsumerState<SharedVaultScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final passwordsAsync = ref.watch(sharedVaultPasswordsProvider(
        (teamId: widget.teamId, vaultId: widget.vault.id)));

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.vault.name,
              style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // We don't have direct access to _showEditVaultDialog from here easily unless we pass it or move it.
                // For now, let's just show a snappy "Not implemented" or refactor.
                // Ideally, edit logic should be accessible.
                // Actually, the user asked to "see the vault and it's contents".
                // We'll leave edit button here but maybe implement later or navigate back to edit.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Edit via Team Screen for now")));
              },
            )
          ],
        ),
        body: passwordsAsync.when(
          data: (passwords) {
            if (passwords.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open,
                        size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text("No passwords in this vault",
                        style: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.8))),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: passwords.length,
              itemBuilder: (context, index) {
                final password = passwords[index];
                return _buildPasswordTile(password, isDark);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text("Error: $e")),
        ));
  }

  Widget _buildPasswordTile(PasswordModel password, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PasswordDetailsScreen(password: password)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isDark ? AppColors.darkBgSecondary : AppColors.lightBgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  password.title.isNotEmpty
                      ? password.title[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.purple,
                      fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(password.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                Text(password.username,
                    style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13)),
              ],
            )),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
