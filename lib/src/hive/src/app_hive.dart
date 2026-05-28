import 'dart:developer' as dev;
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../default_hive_box_names.dart';

/// Simple helper around a Hive box for application-level storage.
///
/// Provides convenience methods for `initialize`, `setData`, `getData`, and
/// watching changes by key.
class AppHive<T> {
  final String boxName;

  Box<T>? _box;

  bool get isInitialized => _box != null;

  AppHive({this.boxName = kAppBoxName});

  Future<void> initialize() async => _box = await Hive.openBox(boxName);

  Future<void> setData({required String key, required T value}) async {
    if (_box == null || !_box!.isOpen) {
      dev.log("Hive box was not initialized!");
      return;
    }
    return _box?.put(key, value);
  }

  T? getData({required String key}) {
    if (_box == null || !_box!.isOpen) {
      dev.log("Hive box was not initialized!");
      return null;
    }
    return _box?.get(key);
  }

  Future<void> deleteData({required String key}) async {
    if (_box == null || !_box!.isOpen) {
      dev.log("Hive box was not initialized!");
      return;
    }
    return _box?.delete(key).then((v) => v);
  }

  Stream<void> watchChanges({required String key}) async* {
    if (_box == null || !_box!.isOpen) {
      dev.log("Hive box was not initialized!");
      return;
    }
    yield* _box!.watch(key: key);
  }

  Stream<T?> watchData({required String key}) async* {
    if (_box == null || !_box!.isOpen) {
      dev.log("Hive box was not initialized!");
      return;
    }
    yield (getData(key: key));
    yield* _box!.watch(key: key).asyncMap((e) => e.value);
  }

  Future<bool> resetAll(String acknowledge) {
    if (_box == null || !_box!.isOpen) {
      dev.log("Hive box was not initialized!");
      return Future.value(false);
    }
    return _box!.clear().then((_) => true).catchError((_) => false);
  }
}
