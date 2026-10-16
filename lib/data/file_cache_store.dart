import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'noor_store.dart';

/// Phase 6D: Dedicated file-based binary cache storage.
///
/// Decouples multi-megabyte binary payloads (like GZipped Hadith editions and offline
/// Quran chunks) from SharedPreferences, completely preventing Android main-thread XML
/// parsing ANRs and iOS NSUserDefaults bloat.
class FileCacheStore {
  FileCacheStore._();
  static final FileCacheStore instance = FileCacheStore._();

  static Directory? _cachedDir;

  static Future<Directory?> _getDirectory() async {
    if (kIsWeb) return null;
    if (_cachedDir != null) return _cachedDir;
    try {
      final base = await getApplicationSupportDirectory();
      final cacheDir = Directory('${base.path}/noor_blobs');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      _cachedDir = cacheDir;
      return cacheDir;
    } catch (_) {
      return null;
    }
  }

  /// Writes raw binary bytes to dedicated file storage.
  /// Seamlessly falls back to [NoorStore] on web or environments where local file system is unavailable.
  static Future<void> writeBytes(String key, List<int> bytes) async {
    final dir = await _getDirectory();
    if (dir != null) {
      try {
        final safeKey = _safeFilename(key);
        final file = File('${dir.path}/$safeKey.bin');
        await file.writeAsBytes(bytes, flush: true);
        return;
      } catch (e) {
        debugPrint('FileCacheStore: writeBytes failed for $key: $e');
      }
    }
    // Fallback to NoorStore for web or mocked environments
    await NoorStore.cacheJson('file.$key', base64Encode(bytes));
  }

  /// Reads raw binary bytes from dedicated file storage.
  static Future<Uint8List?> readBytes(String key) async {
    final dir = await _getDirectory();
    if (dir != null) {
      try {
        final safeKey = _safeFilename(key);
        final file = File('${dir.path}/$safeKey.bin');
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      } catch (e) {
        debugPrint('FileCacheStore: readBytes error for $key: $e');
      }
    }
    // Fallback to NoorStore
    final fallback = await NoorStore.cachedJson('file.$key');
    if (fallback != null && fallback.isNotEmpty) {
      try {
        return base64Decode(fallback);
      } catch (e) {
        debugPrint('FileCacheStore: fallback base64Decode error for $key: $e');
      }
    }
    return null;
  }

  /// Deletes cached file entry.
  static Future<void> delete(String key) async {
    final dir = await _getDirectory();
    if (dir != null) {
      try {
        final safeKey = _safeFilename(key);
        final file = File('${dir.path}/$safeKey.bin');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('FileCacheStore: delete error for $key: $e');
      }
    }
    await NoorStore.cacheJson('file.$key', '');
  }

  static String _safeFilename(String key) =>
      key.replaceAll(RegExp(r'[^a-zA-Z0-9_\-\.]'), '_');

  @visibleForTesting
  static void resetForTesting() {
    _cachedDir = null;
  }
}
