import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import 'vault_provider.dart';
import 'add_password_screen.dart';

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passwords = ref.watch(vaultProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {
              ref.read(authProvider.notifier).lock();
            },
          ),
        ],
      ),
      body: passwords.isEmpty
          ? const Center(child: Text('No passwords stored yet'))
          : ListView.builder(
              itemCount: passwords.length,
              itemBuilder: (context, index) {
                final item = passwords[index];
                return ListTile(
                  title: Text(item.title.isNotEmpty ? item.title : 'Untitled'),
                  subtitle: Text(item.username),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      ref.read(vaultProvider.notifier).deletePassword(item);
                    },
                  ),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: item.password));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password copied to clipboard')),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
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