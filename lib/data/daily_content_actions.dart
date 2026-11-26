import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'daily_content_service.dart';
import 'noor_store.dart';
import 'quran_service.dart';
import 'male_narration.dart';

class DailyBookmarks {
  static String id(DailyContentItem item, String kind) => '$kind:${item.id}';
  static Future<bool> isSaved(DailyContentItem item, String kind) =>
      NoorStore.isBookmarked(id(item, kind));
  static Future<bool> toggle(DailyContentItem item, String kind) async {
    final key = id(item, kind);
    final saved = await NoorStore.toggleBookmark(key);
    if (saved) {
      await NoorStore.saveRichItem(
          id: key,
          title: '${item.title} (${item.reference})',
          subtitle: item.translation,
          tag: kind == 'dua'
              ? 'Dua'
              : kind == 'hadith'
                  ? 'Hadith'
                  : 'Ayah');
    } else {
      await NoorStore.removeRichItem(key);
    }
    return saved;
  }
}

/// Recorded recitation for Quran; explicitly labelled device speech for prose.
class DailyContentPlayback extends ChangeNotifier {
  AudioPlayer? _player;
  FlutterTts? _tts;
  StreamSubscription<PlayerState>? _subscription;
  String? currentItemId;
  bool playing = false;
  bool loading = false;
  String? error;
  bool _disposed = false;
  int _generation = 0;

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> selectNarrator(BuildContext context,
      {String language = 'ar'}) async {
    await stop();
    _tts ??= FlutterTts();
    if (!context.mounted) return;
    try {
      await MaleNarration.choose(context, _tts!, language, force: true);
    } catch (exception) {
      error = exception is NarrationException
          ? exception.message
          : 'Speech voices are unavailable on this device.';
      _changed();
    }
  }

  Future<void> stop() async {
    _generation++;
    playing = false;
    loading = false;
    _changed();
    try {
      await _player?.stop();
      await _tts?.stop();
    } catch (_) {}
  }

  Future<void> toggle(DailyContentItem item,
      {bool quran = false,
      String language = 'ar',
      BuildContext? context}) async {
    if (playing || loading) {
      final same = currentItemId == item.id;
      await stop();
      if (same) return;
    }
    currentItemId = item.id;
    final generation = ++_generation;
    loading = true;
    error = null;
    _changed();
    try {
      if (quran) {
        final match =
            RegExp(r'(\d+):(\d+)(?:[-–](\d+))?').firstMatch(item.reference);
        if (match == null) throw StateError('Verse reference unavailable');
        final surah = await QuranService().fetchSurah(int.parse(match[1]!));
        if (_disposed || generation != _generation) return;
        final first = int.parse(match[2]!);
        final last = int.tryParse(match[3] ?? '') ?? first;
        final ayahs = surah.ayahs
            .where((a) => a.numberInSurah >= first && a.numberInSurah <= last)
            .toList();
        if (ayahs.isEmpty) throw StateError('Recitation unavailable');
        _player ??= AudioPlayer();
        _subscription ??= _player!.playerStateStream.listen((state) {
          playing = state.playing &&
              state.processingState != ProcessingState.completed;
          _changed();
        });
        await _player!
            .setAudioSources(ayahs
                .map((a) => AudioSource.uri(
                    Uri.parse(QuranService.ayahAudioUrl(a.globalNumber))))
                .toList())
            .timeout(const Duration(seconds: 20));
        if (_disposed || generation != _generation) return;
        loading = false;
        playing = true;
        _changed();
        // play completes at the end, so catch asynchronous decoder/network errors.
        unawaited(_player!.play().catchError((Object e) {
          if (!_disposed && generation == _generation) {
            playing = false;
            error =
                'Recitation could not play. Check your connection and retry.';
            _changed();
          }
        }));
      } else {
        _tts ??= FlutterTts();
        _tts!.setCompletionHandler(() {
          playing = false;
          _changed();
        });
        _tts!.setErrorHandler((message) {
          playing = false;
          error =
              'Device speech is unavailable. Install an Arabic voice in Android speech settings.';
          _changed();
        });
        if (await _tts!.isLanguageAvailable(language) != true) {
          throw StateError('Arabic voice unavailable');
        }
        await _tts!.setLanguage(language);
        if (context == null || !context.mounted) {
          throw const NarrationException(
              'Choose a male narrator using the card’s Listen button.');
        }
        final voice = await MaleNarration.choose(context, _tts!, language);
        if (_disposed || generation != _generation) return;
        if (voice == null) {
          loading = false;
          _changed();
          return;
        }
        await _tts!.setVoice(voice);
        await _tts!.setPitch(1.0);
        await _tts!.setSpeechRate(0.4);
        if (_disposed || generation != _generation) return;
        loading = false;
        playing = true;
        _changed();
        final result = await _tts!.speak(item.arabic);
        if (result != 1) throw StateError('Speech unavailable');
      }
    } catch (exception) {
      if (!_disposed && generation == _generation) {
        playing = false;
        loading = false;
        error = exception is NarrationException
            ? exception.message
            : quran
                ? 'Recitation unavailable. Check your connection and try again.'
                : 'Device speech is unavailable for this language. Install a matching voice in Android speech settings.';
        _changed();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    unawaited(_subscription?.cancel());
    unawaited(_player?.dispose());
    unawaited(_tts?.stop());
    super.dispose();
  }
}
