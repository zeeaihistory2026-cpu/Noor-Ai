// NOTE: Native Firestore SDK is not in pubspec.yaml because the app uses pure
// REST APIs in lib/data/firebase_rest_service.dart.
// If you configure native Cloud Firestore in the future, uncomment the code below and
// add cloud_firestore and firebase_auth to pubspec.yaml.
/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Complete Firestore database for NOOR AI Companion.
///
/// Structure:
/// users/{uid}
///   - name, email, createdAt, language, madhhab, goal
///   - prayerLogs/{yyyy-MM-dd} -> {fajr, dhuhr, asr, maghrib, isha: bool}
///   - zikrLogs/{yyyy-MM-dd} -> {counts: {dhikrId: count}}
///   - quranProgress/{surahNumber} -> {lastAyah, completed: bool}
///   - bookmarks/ -> {type, refId, title, createdAt}
///   - streaks -> {salah: {current, longest, lastDate}, zikr: {...}, quran: {...}}
///   - preferences -> {notifications, theme, arabicFont, translation}
///   - reminders/ -> {title, time, type, enabled}
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  String? get _uid => fb.FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDoc =>
      _uid == null ? null : _db.collection('users').doc(_uid);

  /// Ensure the user document exists with default structure.
  Future<void> ensureUserDoc(String name, String email) async {
    final doc = _userDoc;
    if (doc == null) return;
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'language': 'en',
        'madhhab': 'hanafi',
        'goal': '',
        'streaks': {
          'salah': {'current': 0, 'longest': 0, 'lastDate': ''},
          'zikr': {'current': 0, 'longest': 0, 'lastDate': ''},
          'quran': {'current': 0, 'longest': 0, 'lastDate': ''},
        },
        'preferences': {
          'notifications': true,
          'arabicFont': 'amiri',
          'translation': 'en',
          'dailyAyah': true,
          'dailyHadith': true,
        },
      });
    }
  }

  // --- Prayer logs ---
  Future<void> logPrayer(String date, String prayer, bool done) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.collection('prayerLogs').doc(date).set(
      {prayer: done, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Future<Map<String, dynamic>?> getPrayerLog(String date) async {
    final doc = _userDoc;
    if (doc == null) return null;
    final snap = await doc.collection('prayerLogs').doc(date).get();
    return snap.data();
  }

  // --- Zikr logs ---
  Future<void> logZikr(String date, String dhikrId, int count) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.collection('zikrLogs').doc(date).set(
      {
        'counts.$dhikrId': count,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // --- Quran progress ---
  Future<void> saveQuranProgress(int surah, int ayah) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.collection('quranProgress').doc('$surah').set(
      {
        'lastAyah': ayah,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // --- Bookmarks ---
  Future<void> addBookmark({
    required String type, // 'ayah' | 'hadith' | 'dua'
    required String refId,
    required String title,
  }) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.collection('bookmarks').add({
      'type': type,
      'refId': refId,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark(String bookmarkId) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.collection('bookmarks').doc(bookmarkId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> bookmarksStream() {
    final doc = _userDoc;
    if (doc == null) return const Stream.empty();
    return doc
        .collection('bookmarks')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // --- Streaks ---
  Future<void> updateStreak(String kind, int current, int longest) async {
    final doc = _userDoc;
    if (doc == null) return;
    final today = DateTime.now().toIso8601String().split('T').first;
    await doc.set({
      'streaks.$kind': {
        'current': current,
        'longest': longest,
        'lastDate': today,
      },
    }, SetOptions(merge: true));
  }

  // --- Preferences ---
  Future<void> savePreferences(Map<String, dynamic> prefs) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.set({'preferences': prefs}, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getPreferences() async {
    final doc = _userDoc;
    if (doc == null) return null;
    final snap = await doc.get();
    return (snap.data()?['preferences'] as Map<String, dynamic>?);
  }

  // --- Reminders ---
  Future<void> addReminder({
    required String title,
    required String time,
    required String type,
  }) async {
    final doc = _userDoc;
    if (doc == null) return;
    await doc.collection('reminders').add({
      'title': title,
      'time': time,
      'type': type,
      'enabled': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> remindersStream() {
    final doc = _userDoc;
    if (doc == null) return const Stream.empty();
    return doc.collection('reminders').orderBy('time').snapshots();
  }
}
*/
