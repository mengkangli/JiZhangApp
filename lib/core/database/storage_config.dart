import 'package:shared_preferences/shared_preferences.dart';

enum StorageMode { local, remote }

class StorageConfig {
  static const _key = 'storage_mode';

  static Future<StorageMode> getMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key) ?? 'local';
    return value == 'remote' ? StorageMode.remote : StorageMode.local;
  }

  static Future<void> setMode(StorageMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == StorageMode.remote ? 'remote' : 'local');
  }

  /// Remote server URL. Change this to your actual server address.
  static String remoteUrl = 'http://10.0.2.2:5000'; // Android emulator → host localhost
}
