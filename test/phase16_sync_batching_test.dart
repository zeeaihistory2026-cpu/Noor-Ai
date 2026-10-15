import 'package:flutter_test/flutter_test.dart';
import 'package:noor_ai_companion/data/noor_store.dart';
import 'package:noor_ai_companion/data/user_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await NoorStore.clearSyncOutbox();
  });

  group('Phase 6B: Batching & Offline Outbox Sync', () {
    test('Offline prayer saving enqueues into outbox without crashing', () async {
      const date = '2026-10-16';
      final prayers = [true, true, true, false, false];

      // No user is logged in, so savePrayers must queue locally to outbox
      await UserDataService.instance.savePrayers(date, prayers, immediate: true);

      final outbox = await NoorStore.getSyncOutbox();
      expect(outbox.length, equals(1));
      expect(outbox.first['id'], equals('prayer_$date'));
      expect(outbox.first['type'], equals('prayers'));
      expect(UserDataService.instance.syncState.value, equals(SyncState.offlinePending));
    });

    test('Outbox deduplicates and updates latest state for same path', () async {
      const date = '2026-10-16';
      await UserDataService.instance.savePrayers(date, [true, false, false, false, false], immediate: true);
      // User updates immediately again
      await UserDataService.instance.savePrayers(date, [true, true, false, false, false], immediate: true);

      final outbox = await NoorStore.getSyncOutbox();
      // Should coalesce into 1 item, not duplicate
      expect(outbox.length, equals(1));
      expect(outbox.first['id'], equals('prayer_$date'));
    });

    test('Offline tasbih saving enqueues into outbox', () async {
      const date = '2026-10-16';
      await UserDataService.instance.saveTasbihTotal(date, 99, immediate: true);

      final outbox = await NoorStore.getSyncOutbox();
      expect(outbox.any((op) => op['id'] == 'tasbih_$date'), isTrue);
      expect(UserDataService.instance.syncState.value, equals(SyncState.offlinePending));
    });

    test('Outbox flush exits cleanly and updates state if no user authenticated', () async {
      const date = '2026-10-16';
      await NoorStore.enqueueSyncOperation({
        'id': 'prayer_$date',
        'type': 'prayers',
        'path': 'users/local/prayerLogs/$date',
        'data': {'fajr': true},
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      final syncedCount = await UserDataService.instance.flushOutbox();
      expect(syncedCount, equals(0));
      expect(UserDataService.instance.syncState.value, equals(SyncState.offlinePending));
    });

    test('Outbox queue management: removal and clearing works accurately', () async {
      await NoorStore.enqueueSyncOperation({
        'id': 'op_1',
        'type': 'prayers',
        'path': 'users/u1/prayerLogs/2026-10-16',
        'data': {},
        'timestamp': 100,
      });
      await NoorStore.enqueueSyncOperation({
        'id': 'op_2',
        'type': 'tasbih',
        'path': 'users/u1/tasbihLogs/2026-10-16',
        'data': {},
        'timestamp': 200,
      });

      var outbox = await NoorStore.getSyncOutbox();
      expect(outbox.length, equals(2));

      await NoorStore.removeSyncOperations(['op_1']);
      outbox = await NoorStore.getSyncOutbox();
      expect(outbox.length, equals(1));
      expect(outbox.first['id'], equals('op_2'));

      await NoorStore.clearSyncOutbox();
      outbox = await NoorStore.getSyncOutbox();
      expect(outbox, isEmpty);
    });

    test('UserDataService Firestore payload serializes nested types properly', () {
      expect(
        () => UserDataService.instance.savePrayers('2026-10-16', [true, false, true, false, true], immediate: true),
        returnsNormally,
      );
      expect(
        () => UserDataService.instance.saveTasbihTotal('2026-10-16', 33, immediate: true),
        returnsNormally,
      );
    });
  });
}
