import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'package:kickin_storage/kickin_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pathProviderChannel, (
      MethodCall methodCall,
    ) async {
      switch (methodCall.method) {
        case 'getApplicationDocumentsDirectory':
        case 'getTemporaryDirectory':
        case 'getApplicationSupportDirectory':
        case 'getLibraryDirectory':
        case 'getExternalStorageDirectory':
          return Directory.systemTemp.path;
        default:
          return Directory.systemTemp.path;
      }
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      pathProviderChannel,
      null,
    );
  });

  test('initializes and uses an app Hive box', () async {
    await KHive.on.initialize();

    final boxName = 'kickin_storage_test_${DateTime.now().microsecondsSinceEpoch}';
    final appHive = AppHive<String>(boxName: boxName);

    await appHive.initialize();
    addTearDown(() async {
      await Hive.close();
      await Hive.deleteBoxFromDisk(boxName);
    });

    expect(appHive.isInitialized, true);

    await appHive.setData(key: 'theme', value: 'dark');
    expect(appHive.getData(key: 'theme'), 'dark');

    await appHive.deleteData(key: 'theme');
    expect(appHive.getData(key: 'theme'), isNull);
  });
}
