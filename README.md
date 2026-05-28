# kickin_storage `#experimental`

Kickin is a modern modular toolkit designed to turbocharge your Flutter development and eliminate boilerplate. It provides curated utilities, elegant extensions, and standardized architectures for common tasks like networking, state management, and storage.

This is the **#storage** part of it.

---

## ✨ What's in the box

| Class | Description |
|---|---|
| `KHive` | Singleton entry point — initialises and owns all three box types |
| `AppHive<T>` | General-purpose synchronous key-value box |
| `KLazyHive<T>` | Lazy-loaded box for large or infrequently accessed data |
| `KSecureHive<T>` | AES-encrypted box backed by `flutter_secure_storage` |

---

## 💾 Storage

A unified abstraction for local persistent storage, designed to support multiple drivers. **Hive is the first driver — more are on the way.**

### Hive

Powered by [`hive_ce_flutter`](https://pub.dev/packages/hive_ce_flutter). Three box flavours let you match storage strategy to data sensitivity and size.

#### `AppHive` — general purpose

Synchronous reads, async writes. Best for app preferences, UI state, and cached API responses that don't need encryption.

```dart
await KHive.on.app.setData(key: 'theme', value: 'dark');
final theme = KHive.on.app.getData(key: 'theme'); // sync
```

Supports reactive access via two stream variants:

- `watchChanges(key:)` — emits a raw `BoxEvent` on every write to that key.
- `watchData(key:)` — emits the current value immediately, then re-emits the new value on every subsequent write. Typed as `Stream<T?>`.

```dart
KHive.on.app.watchData(key: 'theme').listen((theme) {
  print('theme changed to $theme');
});
```

#### `KLazyHive` — large or infrequently accessed data

Values are loaded from disk only when explicitly requested (`getData` is async). Use for cached API payloads, media metadata, or anything where you don't want the whole box in memory.

```dart
await KHive.on.lazy.setData(key: 'cached_items', value: ['a', 'b']);
final items = await KHive.on.lazy.getData(key: 'cached_items'); // async
```

Shares the same `watchChanges` and `watchData` API as `AppHive`, with `watchData` awaiting the lazy read before emitting.

#### `KSecureHive` — sensitive data

Generates a cryptographically random 32-byte AES key on first use, stores it in `flutter_secure_storage`, and uses it to open an encrypted Hive box. Subsequent opens retrieve the same key so data survives restarts.

```dart
await KHive.on.secure.setData(key: 'token', value: 'secret-token');
final token = KHive.on.secure.getData(key: 'token'); // sync after init
```

`resetAll()` on `KSecureHive` deletes both the box contents **and** the encryption key from secure storage — data is unrecoverable after this call.

> **Note:** `AppHive.resetAll` requires an `acknowledge` string parameter as a safeguard against accidental calls. `KSecureHive.resetAll` and `KLazyHive.resetAll` have no such parameter — treat them accordingly.

---

### Initialisation

Call `KHive.on.initialize()` early in `main`, opting in only to the boxes you need. Already-open boxes are skipped safely.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await KHive.on.initialize(
    initApp: true,
    initSecure: true,
    initLazy: true,
  );

  runApp(const MyApp());
}
```

Individual boxes can also be initialised on demand — `KHive` guards against double-init:

```dart
if (!KHive.on.app.isInitialized) await KHive.on.app.initialize();
```

---

### Usage

```dart
import 'package:kickin_storage/kickin_storage.dart';

enum StorageKey { theme, token, cachedFeed }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await KHive.on.initialize(initApp: true, initSecure: true, initLazy: true);

  // General
  await KHive.on.app.setData(key: StorageKey.theme.name, value: 'dark');
  final theme = KHive.on.app.getData(key: StorageKey.theme.name);

  // Secure
  await KHive.on.secure.setData(key: StorageKey.token.name, value: 'secret-token');
  final token = KHive.on.secure.getData(key: StorageKey.token.name);

  // Lazy
  await KHive.on.lazy.setData(key: StorageKey.cachedFeed.name, value: ['a', 'b']);
  final feed = await KHive.on.lazy.getData(key: StorageKey.cachedFeed.name);

  // Reactive
  KHive.on.app.watchData(key: StorageKey.theme.name).listen((v) => print(v));
}
```

---

## 🔮 Roadmap

Hive is the first storage driver. Planned additions include:

- `SharedPreferences` driver for simple primitive storage
- `SQLite` driver via `drift` for relational data
- Unified `KStorage` abstraction across all drivers

---

## 📦 Installation

```sh
flutter pub add kickin_storage
```

Or add manually to `pubspec.yaml`:

```yaml
dependencies:
  kickin_storage: 0.0.1-dev.3
```

**Dependencies:** [`hive_ce_flutter`](https://pub.dev/packages/hive_ce_flutter) · [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage)