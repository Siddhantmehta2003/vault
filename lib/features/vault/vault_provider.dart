import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'models/password_model.dart';

final vaultProvider = StateNotifierProvider<VaultNotifier, List<PasswordModel>>((ref) {
  return VaultNotifier();
});

class VaultNotifier extends StateNotifier<List<PasswordModel>> {
  VaultNotifier() : super([]) {
    _loadPasswords();
  }

  void _loadPasswords() {
    final box = Hive.box<PasswordModel>('passwords');
    state = box.values.toList();
  }

  Future<void> addPassword(PasswordModel password) async {
    final box = Hive.box<PasswordModel>('passwords');
    await box.add(password);
    _loadPasswords();
  }

  Future<void> deletePassword(PasswordModel password) async {
    await password.delete();
    _loadPasswords();
  }
}
