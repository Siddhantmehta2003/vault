import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:password_manager/core/theme/app_theme.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  bool? _isSetup;
  bool _isLoading = true;
  bool _canCheckBiometrics = false;
  bool _obscurePassword = true;
  bool _isLoginLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _checkSetup();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _checkSetup() async {
    try {
      final isSetup = await ref.read(authProvider.notifier).isPasswordSet();

      bool canCheck = false;
      bool isSupported = false;

      try {
        canCheck = await auth.canCheckBiometrics;
        isSupported = await auth.isDeviceSupported();
      } catch (_) {
        // Biometric not available
      }

      if (mounted) {
        final savedUsername = await ref.read(apiServiceProvider).getUsername();
        if (savedUsername != null) {
          _usernameController.text = savedUsername;
        }
        setState(() {
          _isSetup = isSetup;
          _canCheckBiometrics = canCheck && isSupported;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (_) {
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
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.purple),
              const SizedBox(height: 24),
              Text(
                'Initializing...',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isSetup == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'System Error',
            style: TextStyle(color: AppColors.red),
          ),
        ),
      );
    }

    final isSetup = _isSetup!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: AppColors.purple,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.syne(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Vault',
                          style: TextStyle(color: AppColors.purple),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSetup ? 'Welcome back' : 'Create your master password',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Signup Fields (Email & Username) - Only shown during first setup
                  if (!isSetup) ...[
                    // Email Field
                    _buildInputField(
                      controller: _emailController,
                      hint: 'Email Address',
                      icon: Icons.email_outlined,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    // Username Field
                    _buildInputField(
                      controller: _usernameController,
                      hint: 'Username',
                      icon: Icons.person_outline,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Password Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        width: 2,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                      ),
                      cursorColor: AppColors.purple,
                      decoration: InputDecoration(
                        hintText:
                            isSetup ? 'Enter password' : 'Create password',
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.3),
                          letterSpacing: 0,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.purple,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      onSubmitted: (_) => _submit(isSetup),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          _isLoginLoading ? null : () => _submit(isSetup),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoginLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              isSetup ? 'Unlock' : 'Create Account & Vault',
                              style: GoogleFonts.syne(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),

                  // Biometric Button
                  if (isSetup && _canCheckBiometrics) ...[
                    const SizedBox(height: 32),
                    const Text(
                      'or',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _authenticateWithBiometrics,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBgSecondary
                              : AppColors.lightBgSecondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.fingerprint,
                          size: 36,
                          color: AppColors.purple,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Use Biometrics',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Scan your biometric to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
      if (authenticated && mounted) {
        ref.read(authProvider.notifier).unlockWithBiometrics();
      }
    } on PlatformException catch (e) {
      if (mounted) _showError(e.message ?? 'Biometric Error');
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppColors.purple,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.purple),
          hintStyle: TextStyle(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Future<void> _submit(bool isSetup) async {
    final password = _controller.text;
    if (password.isEmpty) {
      _showError('Password is required');
      return;
    }

    setState(() => _isLoginLoading = true);

    try {
      if (!isSetup) {
        if (password.length < 4) {
          _showError('Password too short (min 4 characters)');
          return;
        }
        if (_emailController.text.isEmpty || _usernameController.text.isEmpty) {
          _showError('All fields are required for setup');
          return;
        }

        // 1. Initial local setup
        await ref.read(authProvider.notifier).setPassword(password);

        // 2. Backend registration
        await ref.read(authProvider.notifier).register(
              email: _emailController.text,
              username: _usernameController.text,
              password: password, // For simplicity using same for both
              masterPassword: password,
            );

        if (mounted) setState(() => _isSetup = true);
      } else {
        // Unlock locally first to check if password is correct
        final isValid =
            await ref.read(authProvider.notifier).verifyPassword(password);
        if (!isValid) {
          _showError('Incorrect password');
          return;
        }

        // Then login to backend
        final username = _usernameController.text;
        if (username.isNotEmpty) {
          await ref.read(authProvider.notifier).login(
                username: username,
                password: password,
                masterPassword: password,
              );
        } else {
          // Fallback if username missing, though it shouldn't be
          await ref.read(authProvider.notifier).unlock(password);
        }
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoginLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
