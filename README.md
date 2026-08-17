# kickin_storage

A Flutter package for simple, reliable local storage. It wraps [Hive](https://pub.dev/packages/hive_ce_flutter) with three ready-to-use box types: general, encrypted, and lazy-loaded.

Part of the **Kickin** toolkit for Flutter.

---

## Installation

```sh
flutter pub add kickin_storage
```

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  kickin_storage: ^0.0.2
```

---

## How it works

Everything goes through a single singleton: `KHive.on`. It owns three box types, each suited to a different use case:

| Box | Access | Use for |
|---|---|---|
| `KHive.on.app` (`AppHive`) | Sync reads, async writes | Preferences, UI state, cached responses |
| `KHive.on.lazy` (`KLazyHive`) | Async reads and writes | Large data you don't want fully in memory |

---

## Quick start

### Step 1 — Initialize in `main`

Call `KHive.on.initialize()` before `runApp`, opting in to only the boxes you need:

```dart
import 'package:kickin_storage/kickin_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await KHive.on.initialize(
    initApp: true,     // general storage
    initLazy: true,    // lazy-loaded storage
  );

  runApp(const MyApp());
}
```

### Step 2 — Read and write

```dart
// General storage
await KHive.on.app.setData(key: 'theme', value: 'dark');
final theme = KHive.on.app.getData(key: 'theme'); // sync

// Lazy storage (large data)
await KHive.on.lazy.setData(key: 'feed', value: ['item1', 'item2']);
final feed = await KHive.on.lazy.getData(key: 'feed'); // async
```

That's it. No setup beyond initialization.

---

## Box types in detail

### `AppHive` — general purpose

Best for app settings, UI state, and cached data that doesn't need encryption.

- Reads are **synchronous** (the whole box is in memory).
- Writes are **asynchronous**.

```dart
await KHive.on.app.setData(key: 'onboarded', value: true);
final onboarded = KHive.on.app.getData(key: 'onboarded'); // bool?
await KHive.on.app.deleteData(key: 'onboarded');
```

> `resetAll` requires an `acknowledge` string to prevent accidental data loss.

---

### `KLazyHive` — lazy-loaded storage

Values are only loaded from disk when you explicitly request them. Use this for large datasets like cached API payloads or media metadata where loading everything into memory upfront is wasteful.

- Reads are **asynchronous** (fetched from disk on demand).
- Writes are **asynchronous**.

```dart
await KHive.on.lazy.setData(key: 'articles', value: articleList);
final articles = await KHive.on.lazy.getData(key: 'articles');
```

---

## Reactive updates (watching changes)

Both `AppHive` and `KLazyHive` support listening to key changes in real time:

```dart
// Emits the current value immediately, then re-emits on every change
KHive.on.app.watchData(key: 'theme').listen((theme) {
  print('Theme changed to: $theme');
});

// Emits a raw BoxEvent on every write (no initial value)
KHive.on.app.watchChanges(key: 'theme').listen((_) {
  print('theme key was written');
});
```

`KLazyHive.watchData` works the same way, but awaits the async read before emitting the initial value.

---

## Initializing boxes on demand

You don't have to initialize all boxes upfront. You can initialize them individually when needed. `KHive` guards against double-initialization:

```dart
if (!KHive.on.app.isInitialized) {
  await KHive.on.app.initialize();
}
```

---

## Full example

```dart
import 'package:kickin_storage/kickin_storage.dart';

// Use an enum to avoid raw key strings across your codebase
enum StorageKey { theme, authToken, cachedFeed }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await KHive.on.initialize(
    initApp: true,
    initLazy: true,
  );

  // General
  await KHive.on.app.setData(key: StorageKey.theme.name, value: 'dark');
  final theme = KHive.on.app.getData(key: StorageKey.theme.name);
  print('Theme: $theme');

  // Lazy
  await KHive.on.lazy.setData(key: StorageKey.cachedFeed.name, value: ['a', 'b', 'c']);
  final feed = await KHive.on.lazy.getData(key: StorageKey.cachedFeed.name);
  print('Feed: $feed');

  // Reactive
  KHive.on.app.watchData(key: StorageKey.theme.name).listen((v) {
    print('Theme updated: $v');
  });

  runApp(const MyApp());
}
```

---

## API reference summary

| Class | Purpose |
|---|---|
| `KHive` | Singleton entry point that initializes and owns all box types |
| `AppHive` | General-purpose synchronous key-value box |
| `KLazyHive` | Lazy-loaded box for large or infrequently accessed data |

**Shared methods** (available on all box types):

| Method | Description |
|---|---|
| `initialize()` | Opens the box. Must be called before use |
| `setData(key:, value:)` | Stores a value |
| `getData(key:)` | Retrieves a value (sync on `AppHive`, async on `KLazyHive`) |
| `deleteData(key:)` | Removes a key |
| `resetAll(...)` | Clears all data from the box |
| `watchData(key:)` | Stream of values for a key (current + future changes) |
| `watchChanges(key:)` | Stream of raw box events for a key |

---

> Additional storage drivers (SharedPreferences, SQLite via Drift) are planned for future releases.
