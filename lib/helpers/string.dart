import 'dart:math';

import 'package:encrypt/encrypt.dart';

String generateRandomString(int length) {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final rand = Random.secure();
  return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
}

bool isValidUrl(String url) {
  final domainRegex = RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (domainRegex.hasMatch(url)) {
    return true;
  }

  final uri = Uri.tryParse(url);
  return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
}

String encryptString(String input, String key) {
  final iv = IV.fromSecureRandom(16);
  final encrypter = Encrypter(AES(Key.fromUtf8(key)));
  final encrypted = encrypter.encrypt(input, iv: iv);
  return '${iv.base64}:${encrypted.base64}';
}

String decryptString(String encryptedInput, String key) {
  final parts = encryptedInput.split(':');
  final iv = IV.fromBase64(parts[0]);
  final encrypter = Encrypter(AES(Key.fromUtf8(key)));
  final decrypted = encrypter.decrypt64(parts[1], iv: iv);
  return decrypted;
}
