import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/security/master_password_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<bool> {
  final MasterPasswordService _masterPasswordService = MasterPasswordService();

  AuthNotifier() : super(false);

  Future<bool> isPasswordSet() => _masterPasswordService.isPasswordSet();

  Future<void> setPassword(String password) async {
    await _masterPasswordService.setPassword(password);
  }

  Future<void> unlock(String password) async {
    final isValid = await _masterPasswordService.verifyPassword(password);
    state = isValid;
  }

  void lock() {
    state = false;
  }
}
