import 'dart:developer' as dev;
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../default_hive_box_names.dart';

/// Simple helper around a Lazy Hive box for application-level storage.
///
/// Provides convenience methods for `initialize`, `setData`, `getData`, and
/// watching changes by key.
class KLazyHive<T> {
  /// The name of the Lazy Hive box to open and use.
  final String boxName;

  LazyBox<T>? _box;

  bool get isInitialized => _box != null;

  /// Creates a new instance of [KLazyHive] with the given [boxName].
  KLazyHive({this.boxName = kAppBoxName});

  /// Initializes the Lazy Hive box by opening it.
  Future<void> initialize() async => _box = await Hive.openLazyBox(boxName);

  /// Stores a [value] associated with the given [key] in the lazy box.
  Future<void> setData({required String key, required T value}) async {
    if (_box == null || !_box!.isOpen) {
      dev.log("Lazy Hive box was not initialized!");
      return;
    }
    return _box?.put(key, value);
  }

  /// Retrieves the value associated with the given [key] from the lazy box.
  /// Returns null if the key doesn't exist or if the box is not initialized.
  Future<T?> getData({required String key}) async {
    if (_box == null || !_box!.isOpen) {
      dev.log("Lazy Hive box was not initialized!");
      return null;
    }
    return _box?.get(key);
  }

  /// Deletes the value associated with the given [key] from the lazy box.
  Future<void> deleteData({required String key}) async {
    if (_box == null || !_box!.isOpen) {
      dev.log("Lazy Hive box was not initialized!");
      return;
    }
    return _box?.delete(key);
  }

  /// Watches for changes to the value associated with the given [key].
  Stream<void> watchChanges({required String key}) async* {
    if (_box == null || !_box!.isOpen) {
      dev.log("Lazy Hive box was not initialized!");
      return;
    }
    yield* _box!.watch(key: key);
  }

  /// Watches for changes to the value associated with the given [key] and yields the new value.
  Stream<T?> watchData({required String key}) async* {
    if (_box == null || !_box!.isOpen) {
      dev.log("Lazy Hive box was not initialized!");
      return;
    }
    yield (await getData(key: key));
    yield* _box!.watch(key: key).asyncMap((e) => e.value);
  }

  /// Clears all data from the lazy box.
  Future<bool> resetAll() {
    if (_box == null || !_box!.isOpen) {
      dev.log("Lazy Hive box was not initialized!");
      return Future.value(false);
    }
    return _box!.clear().then((_) => true).catchError((_) => false);
  }
}
