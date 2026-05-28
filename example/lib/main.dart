import 'package:flutter/material.dart';
import 'package:kickin_storage/kickin_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KHive.on.initialize(initApp: true, initLazy: true);
  runApp(const KickinStorageExampleApp());
}

class KickinStorageExampleApp extends StatelessWidget {
  const KickinStorageExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kickin Storage Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F4C81)), useMaterial3: true),
      home: const StorageDemoPage(),
    );
  }
}

class StorageDemoPage extends StatefulWidget {
  const StorageDemoPage({super.key});

  @override
  State<StorageDemoPage> createState() => _StorageDemoPageState();
}

class _StorageDemoPageState extends State<StorageDemoPage> {
  String _status = 'Ready';
  String _themeValue = 'unset';
  String _cachedItemsValue = 'unset';
  String _secureTokenValue = 'unset';

  Future<void> _saveTheme() async {
    await KHive.on.app.setData(key: 'theme', value: 'dark');
    final theme = KHive.on.app.getData(key: 'theme');

    setState(() {
      _themeValue = theme ?? 'missing';
      _status = 'Saved app data';
    });
  }

  Future<void> _saveCachedItems() async {
    await KHive.on.lazy.setData(key: 'cached_items', value: ['a', 'b', 'c']);
    final cachedItems = await KHive.on.lazy.getData(key: 'cached_items');

    setState(() {
      _cachedItemsValue = '${cachedItems ?? 'missing'}';
      _status = 'Saved lazy data';
    });
  }

  Future<void> _saveSecureToken() async {
    await KHive.on.initialize(initSecure: true);
    await KHive.on.secure.setData(key: 'token', value: 'secret-token');
    final token = KHive.on.secure.getData(key: 'token');

    setState(() {
      _secureTokenValue = token ?? 'missing';
      _status = 'Saved secure data';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kickin Storage')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Status: $_status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(onPressed: _saveTheme, child: const Text('Save app value')),
              FilledButton.tonal(onPressed: _saveCachedItems, child: const Text('Save lazy value')),
              OutlinedButton(onPressed: _saveSecureToken, child: const Text('Save secure value')),
            ],
          ),
          const SizedBox(height: 32),
          _ValueCard(title: 'App box value', value: _themeValue),
          const SizedBox(height: 12),
          _ValueCard(title: 'Lazy box value', value: _cachedItemsValue),
          const SizedBox(height: 12),
          _ValueCard(title: 'Secure box value', value: _secureTokenValue),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
