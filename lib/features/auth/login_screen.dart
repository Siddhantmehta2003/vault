import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:password_manager/features/ui/techno_background.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _controller = TextEditingController();
  bool? _isSetup;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    try {
      final isSetup = await ref.read(authProvider.notifier).isPasswordSet();
      if (mounted) {
        setState(() {
          _isSetup = isSetup;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00FFC2))));
    }

    if (_isSetup == null) {
      return const Scaffold(
          body: Center(
              child:
                  Text("System Error", style: TextStyle(color: Colors.red))));
    }

    final isSetup = _isSetup!;

    return Scaffold(
      body: TechnoBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF00FFC2), Color(0xFFD600FF)],
                  ).createShader(bounds),
                  child: const Icon(Icons.lock_outline,
                      size: 80, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'TRIMESHA\nSECURE VAULT',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      const Shadow(color: Color(0xFF00FFC2), blurRadius: 15),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'v1.0.0 :: SYSTEM READY',
                  style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    letterSpacing: 2,
                    fontSize: 12,
                    fontFamily: 'Courier',
                  ),
                ),
                const SizedBox(height: 60),
                TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF00FFC2),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5),
                  cursorColor: const Color(0xFFD600FF),
                  decoration: InputDecoration(
                    labelText:
                        isSetup ? 'ENTER ACCESS CODE' : 'CREATE MASTER CODE',
                    labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        letterSpacing: 2,
                        fontSize: 14),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xFF00FFC2).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xFF00FFC2), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                  onSubmitted: (_) => _submit(isSetup),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _submit(isSetup),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FFC2).withOpacity(0.1),
                      foregroundColor: const Color(0xFF00FFC2),
                      side: const BorderSide(color: Color(0xFF00FFC2)),
                      shadowColor: const Color(0xFF00FFC2),
                      elevation: 10,
                    ),
                    child: Text(
                      isSetup ? 'AUTHENTICATE' : 'INITIALIZE SYSTEM',
                      style: const TextStyle(fontSize: 16, letterSpacing: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(bool isSetup) async {
    if (!isSetup) {
      if (_controller.text.length < 4) {
        _showError('CODE TOO SHORT');
        return;
      }
      await ref.read(authProvider.notifier).setPassword(_controller.text);
      if (mounted) setState(() => _isSetup = true);
      await ref.read(authProvider.notifier).unlock(_controller.text);
    } else {
      await ref.read(authProvider.notifier).unlock(_controller.text);
      final isUnlocked = ref.read(authProvider);
      if (!isUnlocked && mounted) {
        _showError('ACCESS DENIED');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
