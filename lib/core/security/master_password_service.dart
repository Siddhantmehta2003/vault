import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:password_manager/core/security/hash_util.dart';

class MasterPasswordService {
  final _storage = const FlutterSecureStorage();
  static const _key = 'master_password_hash';

  Future<bool> isPasswordSet() async {
    return await _storage.read(key: _key) != null;
    // return savedHashsh != null;
  }

  Future<void> setPassword(String password) async {
    final hash = HashUtil.hashPassword(password);
    await _storage.write(key: _key, value: hash);
  }

  Future<bool> verifyPassword(String password) async {
    final savedHash = await _storage.read(key: _key);
    if (savedHash == null) return false;
    // final inputHash = HashUtil.hashPassword(password);
    return HashUtil.hashPassword(password) == savedHash;
  }

  // Future<void> saveMasterPassword(String passwordHash) async {
  //   await _storage.write(key: _key, value: passwordHash);
  // }

  // Future<String?> getMasterPassword() async {
  //   return await _storage.read(key: _key);
  // }
}