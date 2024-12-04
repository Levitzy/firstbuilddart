// lib/services/netmod_decryptor_screen.dart
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../utils/json_formatter.dart';

class DecryptorService {
  static const String key = "X25ldHN5bmFfbmV0bW9kXw==";

  String decrypt(String encryptedData) {
    try {
      final keyBytes = base64.decode(key);
      final encrypter = encrypt.Encrypter(
          encrypt.AES(encrypt.Key(keyBytes), mode: encrypt.AESMode.ecb));

      final encrypted = base64.decode(encryptedData);
      final decrypted = encrypter.decryptBytes(encrypt.Encrypted(encrypted));

      final decryptedString = utf8.decode(decrypted).trim();
      return _formatDecryptedData(decryptedString);
    } catch (e) {
      return 'Error during decryption: $e';
    }
  }

  String _formatDecryptedData(String decryptedData) {
    try {
      final jsonData = json.decode(decryptedData);
      return JsonFormatter.formatJson(jsonData);
    } catch (e) {
      final jsonObjects = _findJsonObjects(decryptedData);
      if (jsonObjects.isEmpty) {
        return 'No valid JSON objects found.';
      }
      return jsonObjects.map((obj) {
        try {
          return JsonFormatter.formatJson(json.decode(obj));
        } catch (e) {
          return 'Error parsing JSON data: $e';
        }
      }).join('\n\n');
    }
  }

  List<String> _findJsonObjects(String text) {
    List<String> jsonObjects = [];
    int braceCount = 0;
    int startIndex = 0;
    bool inString = false;

    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (char == '"' && (i == 0 || text[i - 1] != '\\')) {
        inString = !inString;
      }
      if (!inString) {
        if (char == '{') {
          if (braceCount == 0) {
            startIndex = i;
          }
          braceCount++;
        } else if (char == '}') {
          braceCount--;
          if (braceCount == 0) {
            jsonObjects.add(text.substring(startIndex, i + 1));
          }
        }
      }
    }
    return jsonObjects;
  }
}