import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: ref.read(authProvider.notifier).isPasswordSet(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final isSetup = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Trimesha Password Manager',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: isSetup ? 'Enter Master Password' : 'Set Master Password',
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (!isSetup) {
                      if (_controller.text.length < 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password too short')),
                        );
                        return;
                      }
                      await ref
                          .read(authProvider.notifier)
                          .setPassword(_controller.text);
                      // Force rebuild or just unlock
                      await ref
                          .read(authProvider.notifier)
                          .unlock(_controller.text);
                    } else {
                      await ref
                          .read(authProvider.notifier)
                          .unlock(_controller.text);
                      
                      // Check if still locked (invalid password)
                      // We can't easily check 'state' here immediately without watching, 
                      // but the parent MyApp watches authProvider, so it will switch screen if unlocked.
                      // If it stays here, show error?
                      // The easiest way is to wait a bit or check the provider again?
                      // Actually, if unlock fails, state remains false.
                    }
                  },
                  child: Text(isSetup ? 'Unlock Vault' : 'Save & Unlock'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}