import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/auth/login_screen.dart';
import 'features/vault/vault_screen.dart';
import 'features/auth/auth_provider.dart';
import 'features/vault/models/password_model.dart';
import 'features/vault/vault_provider.dart'; // Ensure this is imported if used, but we don't access it here.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PasswordModelAdapter());
  await Hive.openBox<PasswordModel>('passwords');
  await Hive.openBox('settings'); // Box for master password hash

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlocked = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trimesha Vault',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050510),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFC2), // Cyber Cyan
          secondary: Color(0xFFD600FF), // Neon Purple
          surface: Color(0xFF101020),
          background: Color(0xFF050510),
          onPrimary: Colors.black,
          onSurface: Color(0xFFE0E0E0),
        ),
        fontFamily: 'Courier', // Monospace for tech feel
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF121225),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF2A2A40)),
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF00FFC2), width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          labelStyle: const TextStyle(color: Color(0xFF8888AA)),
          prefixIconColor: const Color(0xFF00FFC2),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FFC2),
            foregroundColor: const Color(0xFF050510),
            elevation: 10,
            shadowColor: const Color(0xFF00FFC2).withOpacity(0.5),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: const TextStyle(
              fontFamily: 'Courier',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Courier',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FFC2),
            letterSpacing: 2.0,
          ),
          iconTheme: IconThemeData(color: Color(0xFF00FFC2)),
        ),
      ),
      home: isUnlocked ? const VaultScreen() : const LoginScreen(),
    );
  }
}
