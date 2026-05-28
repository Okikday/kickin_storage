import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'src/app_hive.dart';
import 'src/lazy_hive.dart';
import 'src/secure_hive.dart';

/// Top-level helper to initialize and access app and secure Hive boxes.
///
/// Use `KickinHive.on.initialize()` early in your app start-up to ensure
/// the underlying Hive boxes are ready for use.
class KHive<T> {
  static final on = KHive._();
  KHive._();
  static bool _hiveInitialized = false;

  /// Make sure to initialize [KHive] before using
  /// You can use this for your general app storage needs.
  final app = AppHive<T>();

  /// Make sure to initialize [KHive] before using
  /// Use this for sensitive data that requires encryption, like auth tokens or user credentials.
  final secure = KSecureHive<T>();

  /// Make sure to initialize [KHive] before using
  /// Use this for large data that you want to load lazily, like cached API responses or media metadata.
  final lazy = KLazyHive<T>();

  /// If box was already opened, it does nothing. else, it opens the boxes marked as true
  Future<void> initialize({bool initApp = false, bool initSecure = false, bool initLazy = false}) async {
    if (!_hiveInitialized) {
      await Hive.initFlutter();
      _hiveInitialized = true;
    }
    if (initApp && !app.isInitialized) await app.initialize();
    if (initSecure && !secure.isInitialized) await secure.initialize();
    if (initLazy && !lazy.isInitialized) await lazy.initialize();
  }
}
