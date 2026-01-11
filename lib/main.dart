import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/auth/login_screen.dart';
import 'features/vault/vault_screen.dart';
import 'features/auth/auth_provider.dart';
import 'features/vault/models/password_model.dart';
import 'features/vault/vault_provider.dart'; // Ensure this is imported if used, but we don't access it here.

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PasswordModelAdapter());
  await Hive.openBox<PasswordModel>('passwords');
  
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlocked = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isUnlocked ? const VaultScreen() :  LoginScreen(),
    );
  }
}