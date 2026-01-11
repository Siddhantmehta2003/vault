import 'package:hive/hive.dart';
import 'package:password_manager/core/security/hash_util.dart';

class MasterPasswordService {
  static const _key = 'master_password_hash';
  final _box = Hive.box('settings');

  Future<bool> isPasswordSet() async {
    return _box.containsKey(_key);
  }

  Future<void> setPassword(String password) async {
    final hash = HashUtil.hashPassword(password);
    await _box.put(_key, hash);
  }

  Future<bool> verifyPassword(String password) async {
    final savedHash = _box.get(_key);
    if (savedHash == null) return false;
    return HashUtil.hashPassword(password) == savedHash;
  }
}
