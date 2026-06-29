/// A Kickin package providing simple helpers around Hive for app and secure storage.
library;

export 'src/hive/kickin_hive.dart' show KHive;
export 'src/hive/src/app_hive.dart' show AppHive;
export 'src/hive/src/lazy_hive.dart' show KLazyHive;
export 'src/hive/src/secure_hive.dart' show KSecureHive;
export 'src/hive/default_hive_box_names.dart';


/// Import this package as `ks` and use `KHive.on.initialize()` to prepare the Hive boxes.