// lib/services/sockshttp_decryptor_service.dart
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';

class SockshttpDecryptorService {
  static const List<String> configKeys = [
    "162exe235948e37ws6d057d9d85324e2",
    "dyv35182!",
    "dyv35224nossas!!",
    "662ede816988e58fb6d057d9d85605e0",
    "962exe865948e37ws6d057d4d85604e0",
    "175exe868648e37wb9x157d4l45604l0",
    "c7-YOcjyk1k",
    "Wasjdeijs@/ÇPãoOf231#\$%¨&*()_qqu&iJo>ç",
    "Ed\x01",
    "fubvx788b46v",
    "fubgf777gf6",
    "cinbdf665\$4",
    "furious0982",
    "error",
    "Jicv",
    "mtscrypt",
    "62756C6F6B",
    "rdovx202b46v",
    "xcode788b46z",
    "y\$I@no5#lKuR7ZH#eAgORu6QnAF*vP0^JOTyB1ZQ&*w^RqpGkY",
    "kt",
    "fubvx788B4mev",
    "thirdy1996624",
    "bKps&92&",
    "waiting",
    "gggggg",
    "fuMnrztkzbQ",
    "A^ST^f6ASG6AS5asd",
    "cnt",
    "chaveKey",
    "Version6",
    "trfre699g79r",
    "chanika acid, gimsara htpcag!!",
    "xcode788b46z",
    "cigfhfghdf665557",
    "0x0",
    "2\$dOxdIb6hUpzb*Y@B0Nj!T!E2A6DOLlwQQhs4RO6QpuZVfjGx",
    "W0RFRkFVTFRd",
    "Bgw34Nmk",
    "B1m93p\$\$9pZcL9yBs0b\$jJwtPM5VG@Vg",
    "fubvx788b46vcatsn",
    "\$\$\$@mfube11!!_\$\$))012b4u",
    "zbNkuNCGSLivpEuep3BcNA==",
    "175exe867948e37wb9d057d4k45604l0"
  ];

  String? decrypt(String encryptedContent) {
    try {
      final configFile = json.decode(encryptedContent);
      final parts = configFile['d'].split('.');
      final iv = parts[1];
      final data = parts[0];
      final version = configFile['v'];

      String? decryptedData;
      for (final key in configKeys) {
        try {
          final aesKey = base64Encode(utf8.encode(md5crypt('$key $version')));
          final secretKeySpec = encrypt.Key.fromBase64(aesKey);
          final ivParameterSpec = base64.decode(iv);

          final encrypter = encrypt.Encrypter(
            encrypt.AES(secretKeySpec, mode: encrypt.AESMode.cbc),
          );
          final encrypted = encrypt.Encrypted(base64.decode(data));
          decryptedData = encrypter.decrypt(encrypted, iv: encrypt.IV(ivParameterSpec));

          // If we reach here without exception, we found a working key
          break;
        } catch (e) {
          continue;
        }
      }

      if (decryptedData == null) {
        throw Exception('No valid decryption key found');
      }

      return parseConfig(json.decode(decryptedData));
    } catch (e) {
      return 'Decryption failed! Error: $e';
    }
  }

  String parseConfig(Map<String, dynamic> data) {
    List<String> result = [];
    result.add('🎉 Decrypted Content:');

    void addEntry(String key, dynamic value) {
      if (value is Map) {
        result.add('🔑 $key:');
        value.forEach((k, v) => addEntry(k, v));
      } else if (value is List) {
        result.add('🔑 $key: [${value.join(", ")}]');
      } else {
        result.add('🔑 $key: $value');
      }
    }

    data.forEach((key, value) {
      if (key != 'message') {
        addEntry(key, value);
      }
    });

    return result.join('\n');
  }

  String md5crypt(String data) {
    return md5.convert(utf8.encode(data)).toString();
  }
}