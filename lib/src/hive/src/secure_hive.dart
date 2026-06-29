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
  /// The name of the secure Hive box.
  final String secureBoxName;
  /// The key used to store the cipher key in flutter_secure_storage.
  final String secureCipherKey;

  Box<T>? _secureBox;

  bool get isInitialized => _secureBox != null;

  /// Creates a new instance of [KSecureHive] with the given [secureBoxName] and [secureCipherKey].
  KSecureHive({this.secureBoxName = kSecureBoxName, this.secureCipherKey = kSecureBoxName});

  /// Initializes the secure Hive box by retrieving or creating an encryption key, and then opening the box.
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

  /// Stores a [value] associated with the given [key] in the secure box.
  Future<void> setData({required String key, required T value}) async {
    if (_secureBox == null || _secureBox!.isOpen == false) {
      dev.log("Secure Hive box was not initialized!");
      return;
    }
    return _secureBox?.put(key, value);
  }

  /// Retrieves the value associated with the given [key] from the secure box.
  /// Returns null if the key doesn't exist or if the box is not initialized.
  T? getData({required String key}) {
    if (_secureBox == null || _secureBox!.isOpen == false) {
      dev.log("Secure Hive box was not initialized!");
      return null;
    }
    return _secureBox?.get(key);
  }

  /// Clears all data from the secure box and removes the encryption key from flutter_secure_storage.
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
