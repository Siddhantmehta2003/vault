import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_service.dart';
import '../../core/api/models/api_models.dart';
import '../../core/security/master_password_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref.read(apiServiceProvider));
});

final usernameProvider = FutureProvider<String?>((ref) async {
  return await ref.read(apiServiceProvider).getUsername();
});

final emailProvider = FutureProvider<String?>((ref) async {
  // We should also save/get email. For now, let's assume we store it or just return a default
  // Actually, let's add saveEmail to ApiService
  return await ref.read(apiServiceProvider).getEmail();
});

class AuthNotifier extends StateNotifier<bool> {
  final ApiService _apiService;
  final MasterPasswordService _masterPasswordService = MasterPasswordService();

  AuthNotifier(this._apiService) : super(false);

  Future<bool> isPasswordSet() => _masterPasswordService.isPasswordSet();

  Future<void> setPassword(String password) async {
    await _masterPasswordService.setPassword(password);
  }

  Future<bool> verifyPassword(String password) async {
    return _masterPasswordService.verifyPassword(password);
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    required String masterPassword,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        username: username,
        password: password,
        masterPassword: masterPassword,
      );

      await _apiService.register(request);
      await _apiService.saveEmail(email); // Save email locally
      await login(
          username: username,
          password: password,
          masterPassword: masterPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login({
    required String username,
    required String password,
    required String masterPassword,
  }) async {
    try {
      await _apiService.login(username, password);
      await _apiService.saveMasterPassword(masterPassword);
      // We should also save the username for future logins
      await _apiService.saveUsername(username);
      state = true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlock(String password) async {
    final isValid = await _masterPasswordService.verifyPassword(password);
    state = isValid;
  }

  void unlockWithBiometrics() {
    state = true;
  }

  void lock() {
    state = false;
  }

  Future<void> logout() async {
    await _apiService.clearAuth();
    state = false;
  }
}
