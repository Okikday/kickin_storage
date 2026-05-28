import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../default_hive_box_names.dart';

const _secureStorage = FlutterSecureStorage();

/// A small wrapper around Hive that uses a platform secure storage-backed
/// encryption key (via `flutter_secure_storage`) to provide encrypted boxes.
///
/// Typical usage: call `initialize()` before `getData`/`setData`.
class KSecureHive<T> {
  final String secureBoxName;
  final String secureCipherKey;

  Box<T>? _secureBox;

  bool get isInitialized => _secureBox != null;

  KSecureHive({this.secureBoxName = kSecureBoxName, this.secureCipherKey = kSecureBoxName});

  Future<void> initialize() async {
    final cipherKey = await _secureStorage.read(key: secureCipherKey);
    final decodedCipherKey = cipherKey != null
        ? base64Decode(cipherKey).toList()
        : List<int>.generate(32, (i) => Random.secure().nextInt(256));

    if (cipherKey == null) {
      await _secureStorage.write(key: secureCipherKey, value: base64Encode(decodedCipherKey));
    }

    _secureBox = await Hive.openBox(secureBoxName, encryptionCipher: HiveAesCipher(decodedCipherKey));
  }

  Future<void> setData({required String key, required T value}) async {
    if (_secureBox == null || _secureBox!.isOpen == false) {
      dev.log("Secure Hive box was not initialized!");
      return;
    }
    return _secureBox?.put(key, value);
  }

  T? getData({required String key}) {
    if (_secureBox == null || _secureBox!.isOpen == false) {
      dev.log("Secure Hive box was not initialized!");
      return null;
    }
    return _secureBox?.get(key);
  }

  Future<bool> resetAll() async {
    if (_secureBox == null || _secureBox!.isOpen == false) {
      dev.log("Secure Hive box was not initialized!");
      return false;
    }
    return _secureBox!
        .clear()
        .then((_) => _secureStorage.delete(key: secureCipherKey))
        .then((_) => true)
        .catchError((_) => false);
  }
}
