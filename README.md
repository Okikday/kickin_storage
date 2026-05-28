# 🦵 Kickin Storage (#experimental)

Kickin is a modern modular toolkit designed to turbocharge your Flutter development and eliminate boilerplate. It provides curated utilities, elegant extensions, and standardized architectures for common tasks like networking, state management, and storage.

This is the abstracted storage package.

## Installation

Current version: `0.0.1-dev.1`

Add it with:

```bash
flutter pub add kickin_storage
```

Or pin the dependency manually in `pubspec.yaml`:

```yaml
dependencies:
  kickin_storage: ^0.0.1-dev.1
```

### 💾 Storage
A unified abstraction for local persistent storage, architected to support multiple drivers smoothly.

* **Hive**
  A fast key-value storage implementation powered by Hive. Includes app-level, secure, and lazy options.
  * **Key Classes:** `KHive`, `KSecureHive`, `KLazyHive`
  * **Usage:**
    ```dart
    enum KHiveKeys { theme }

    Future<void> main() async {
      await KHive.on.initialize(initApp: true, initSecure: true, initLazy: true);

      await KHive.on.app.setData(key: KHiveKeys.theme.name, value: 'dark');
      final theme = KHive.on.app.getData(key: KHiveKeys.theme.name);

      await KHive.on.secure.setData(key: 'token', value: 'secret-token');
      final token = KHive.on.secure.getData(key: 'token');

      await KHive.on.lazy.setData(key: 'cached_items', value: ['a', 'b']);
      final cachedItems = await KHive.on.lazy.getData(key: 'cached_items');
    }
    ```

Uses `hive_ce_flutter` and `flutter_secure_storage`.

Other storage kinds are on the way.