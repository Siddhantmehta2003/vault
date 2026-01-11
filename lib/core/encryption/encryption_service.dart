import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final _key = Key.fromLength(32);
  final _iv = IV.fromLength(16);

  Encrypter get _encrypter => Encrypter(AES(_key));

  String encryptText(String text) {
    return _encrypter.encrypt(text, iv: _iv).base64;
  }

  String decryptText(String encryptedText) {
    return _encrypter.decrypt64(encryptedText, iv: _iv);
  }
}
