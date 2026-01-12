import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:password_manager/features/ui/techno_background.dart';
import '../auth/auth_provider.dart';
import 'vault_provider.dart';
import 'add_password_screen.dart';

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwords = ref.watch(vaultProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('DATA VAULT'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_open),
            onPressed: () {
              ref.read(authProvider.notifier).lock();
            },
          ),
        ],
      ),
      body: TechnoBackground(
        child: passwords.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sd_storage_outlined,
                        size: 64, color: Colors.white.withValues(alpha:0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'NO ENCRYPTED DATA FOUND',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha:0.5),
                        fontFamily: 'Courier',
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(
                    top: 80, left: 16, right: 16, bottom: 80),
                itemCount: passwords.length,
                itemBuilder: (context, index) {
                  final item = passwords[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101020).withValues(alpha:0.8),
                      border: Border.all(
                        color: const Color(0xFF00FFC2).withValues(alpha:0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FFC2)
                              .withValues(alpha:index % 2 == 0 ? 0.05 : 0),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FFC2).withValues(alpha:0.1),
                          shape: BoxShape.circle,
                        ),
                        child:
                            const Icon(Icons.vpn_key, color: Color(0xFF00FFC2)),
                      ),
                      title: Text(
                        item.title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'USR: ${item.username}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.6),
                              fontFamily: 'Courier',
                            ),
                          ),
                          if (item.url.isNotEmpty)
                            Text(
                              'URL: ${item.url}',
                              style: const TextStyle(
                                color: Color(0xFFD600FF),
                                fontSize: 10,
                                fontFamily: 'Courier',
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy,
                                color: Color(0xFF00FFC2)),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: item.password));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('DECRYPTED TO CLIPBOARD'),
                                  backgroundColor:
                                      const Color(0xFF00FFC2).withValues(alpha:0.2),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.redAccent),
                            onPressed: () {
                              // Confirm dialog could be cool here
                              ref
                                  .read(vaultProvider.notifier)
                                  .deletePassword(item);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00FFC2),
        foregroundColor: Colors.black,
        elevation: 10,
        shape: const RoundedRectangleBorder(), // Square/tech shape
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPasswordScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
