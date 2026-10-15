import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/quran_service.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Page 05 — Quran Audio Player. Full dark emerald page: Now Playing
/// header, cream arch card with the real Al-Kahf calligraphy crop,
/// reciter row, seek slider, transport controls, Speed/Timer/Sleep/
/// Download/Share row, Playback Range, Repetition Settings (−/+ for
/// repeat count and pause seconds), Up Next list and dark bottom
/// mini-player, exactly as drawn.
///
/// Phase 8: wired to QuranService — loads Surah 18 from AlQuran
/// Cloud, builds the real per-ayah audio URLs (Islamic Network CDN,
/// ar.alafasy = the reciter drawn on this page) and the live ayah
/// count / Up Next metadata. Layout is unchanged; sample values on
/// screen until live data lands, and forever when offline.
/// Phase 9: real playback via just_audio (just_audio_web on web) —
/// play/pause/seek/skip come from the player's own streams, the
/// playlist is the per-ayah CDN URLs, and the player is stopped +
/// disposed with the screen. Without live URLs (offline) the
/// transport falls back to the Phase 8 UI state, honestly.
///
/// Phase 16 (Job 7): the screen takes the surah number as a
/// parameter ([surah], default 18 = Al-Kahf as drawn) and builds
/// the per-ayah CDN playlist for that surah end-to-end.
class QuranAudioPlayerScreen extends StatefulWidget {
  const QuranAudioPlayerScreen({super.key, this.surah = 18});

  /// Surah number 1..114. Default 18 (Al-Kahf) preserves the Page 05
  /// design and the existing goldens.
  final int surah;

  @override
  State<QuranAudioPlayerScreen> createState() => _QuranAudioPlayerScreenState();
}

class _QuranAudioPlayerScreenState extends State<QuranAudioPlayerScreen> {
  double _seek = 154; // Sample seek (02:34 of 34:56) until live.
  bool _playing = false;
  bool _autoplay = true;
  int _repeat = 3;
  int _pauseSec = 2;

  // Phase 9 — real player (just_audio). State is driven by the
  // player's streams, never by optimistic UI toggles alone.
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  StreamSubscription<int?>? _idxSub;
  bool _playerReady = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _speed = 1.0;
  int _repeatMode = 0; // 0 off, 1 repeat ayah
  bool _saved = false;

  // Phase 8 live wiring (sample fallback until loaded).
  List<String> _audioUrls = const [];
  late int _ayahIndex; // Ayah 18 for the drawn Al-Kahf view, 1 otherwise.
  int _ayahCount = 110;
  bool _live = false;
  (String, String, String, String)? _upNextA;
  (String, String, String, String)? _upNextB;
  // Header + stats for the chosen surah (drawn values for 18).
  String _surahTitle = 'Surah Al-Kahf';
  String _surahMeaning = 'The Cave';
  String _juzLabel = '15';
  String _pageLabel = '293';

  @override
  void initState() {
    super.initState();
    _ayahIndex = widget.surah == 18 ? 17 : 0;
    _stateSub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state.playing);
      if (state.processingState == ProcessingState.completed && !_autoplay) {
        _player.stop();
      }
    });
    _posSub = _player.positionStream.listen((pos) {
      if (!mounted) return;
      setState(() {
        _position = pos;
        if (_duration.inSeconds > 0) {
          _seek = pos.inSeconds.toDouble();
        }
      });
    });
    _durSub = _player.durationStream.listen((dur) {
      if (!mounted || dur == null) return;
      setState(() => _duration = dur);
    });
    _idxSub = _player.currentIndexStream.listen((idx) {
      if (!mounted || idx == null) return;
      setState(() => _ayahIndex = idx);
    });
    _loadLive();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _posSub?.cancel();
    _durSub?.cancel();
    _idxSub?.cancel();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  /// Loads the per-ayah CDN playlist into the real player.
  Future<void> _initPlayer() async {
    if (_audioUrls.isEmpty) return;
    try {
      await _player.setAudioSources(
        [for (final url in _audioUrls) AudioSource.uri(Uri.parse(url))],
        initialIndex: _ayahIndex.clamp(0, _audioUrls.length - 1),
        initialPosition: Duration.zero,
      );
      await _player.setLoopMode(LoopMode.off);
      await _player.setSpeed(_speed);
      if (mounted) setState(() => _playerReady = true);
    } catch (_) {
      // Stream/CDN unreachable: keep the honest sample UI state.
      if (mounted) setState(() => _playerReady = false);
    }
  }

  Future<void> _togglePlay() async {
    if (_playerReady) {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } else {
      // Offline/sample fallback: UI state only, as in Phase 8.
      setState(() => _playing = !_playing);
    }
  }

  void _cycleSpeed() {
    const speeds = [1.0, 1.25, 1.5, 1.75, 2.0];
    final next = speeds[(speeds.indexOf(_speed) + 1) % speeds.length];
    setState(() => _speed = next);
    if (_playerReady) _player.setSpeed(next);
  }

  /// Phase 16 audit: the header ⋯ opens the same real speed control
  /// as the body's Speed chip.
  void _pickSpeed(double s) {
    setState(() => _speed = s);
    if (_playerReady) _player.setSpeed(s);
  }

  void _openPlayerOptions() => showNoorOverflowSheet(context,
      title: 'Playback options',
      actions: [
        for (final s in const [1.0, 1.25, 1.5, 1.75, 2.0])
          (
            s == _speed
                ? Icons.check_circle
                : Icons.speed_outlined,
            'Speed ${s}x${s == _speed ? ' (current)' : ''}',
            () => _pickSpeed(s)
          ),
      ]);

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  Future<void> _loadLive() async {
    final surah = widget.surah;
    try {
      // The per-ayah CDN playlist for the CHOSEN surah (Job 7):
      // one URL per ayah, in order, via the ayah's global number.
      // (Service is constructed inside the try so even a
      // construction-time failure degrades to the sample UI
      // instead of an unhandled async error.)
      final detail = await QuranService().fetchSurah(surah);
      final urls = QuranService.surahAudioUrls(detail);
      if (!mounted) return;
      setState(() {
        _audioUrls = urls;
        if (detail.ayahs.isNotEmpty) {
          _ayahCount = detail.ayahs.length;
          _ayahIndex = _ayahIndex.clamp(0, _ayahCount - 1);
          final first = detail.ayahs.first;
          if (surah != 18) {
            _juzLabel = first.juz?.toString() ?? '—';
            _pageLabel = first.page?.toString() ?? '—';
          }
        }
        _live = _currentAudioUrl.isNotEmpty;
      });
      await _initPlayer();
    } catch (_) {
      /* sample fallback stays; never break the player screen */
    }
    try {
      final list = await QuranService().fetchSurahListOrFallback();
      if (!mounted) return;
      setState(() {
        if (surah == 18) {
          // Drawn Up Next rows (Maryam / Taha) stay exactly as drawn.
          for (final m in list) {
            if (m.number == 19) {
              _upNextA = (
                '19',
                'Surah ${m.englishName}',
                'Juz 16  •  Page 305',
                '${m.numberOfAyahs} Ayahs'
              );
            }
            if (m.number == 20) {
              _upNextB = (
                '20',
                'Surah ${m.englishName}',
                'Juz 16  •  Page 312',
                '${m.numberOfAyahs} Ayahs'
              );
            }
          }
        } else {
          // For any other surah: the next two surahs (wrap 1<->114),
          // with the translation as the meta line (metadata only).
          final metas = {for (final m in list) m.number: m};
          final here = metas[surah];
          if (here != null) {
            _surahTitle = 'Surah ${here.englishName}';
            _surahMeaning = here.englishNameTranslation;
          }
          final n1 = QuranService.nextSurahNumber(surah);
          final n2 = QuranService.nextSurahNumber(n1);
          final m1 = metas[n1];
          final m2 = metas[n2];
          if (m1 != null) {
            _upNextA = (
              '$n1',
              'Surah ${m1.englishName}',
              m1.englishNameTranslation,
              '${m1.numberOfAyahs} Ayahs'
            );
          }
          if (m2 != null) {
            _upNextB = (
              '$n2',
              'Surah ${m2.englishName}',
              m2.englishNameTranslation,
              '${m2.numberOfAyahs} Ayahs'
            );
          }
        }
      });
    } catch (_) {
      /* design rows remain */
    }
  }



  String get _currentAudioUrl => _audioUrls.isEmpty
      ? ''
      : _audioUrls[_ayahIndex.clamp(0, _audioUrls.length - 1)];

  void _skip(int delta) {
    if (_playerReady) {
      if (delta > 0) {
        _player.seekToNext();
      } else {
        _player.seekToPrevious();
      }
      return;
    }
    setState(() {
      _ayahIndex = (_ayahIndex + delta).clamp(0, _ayahCount - 1);
      _seek = 0;
      _position = Duration.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorColors.emeraldDark,
      body: SafeArea(
        child: Column(children: [
          // Header: back / Now Playing / bookmark •••
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                  child: Text('Now Playing',
                      textAlign: TextAlign.center,
                      style: NoorType.section.copyWith(color: Colors.white))),
              IconButton(
                  icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white),
                  tooltip: _saved ? 'Saved' : 'Save this Surah',
                  onPressed: () => setState(() => _saved = !_saved)),
              IconButton(
                  tooltip: 'Playback options',
                  icon: const Icon(Icons.more_horiz, color: Colors.white),
                  onPressed: _openPlayerOptions),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              children: [
                // Cream arch card with real design art (Page 05 crop).
                Container(
                  decoration: BoxDecoration(
                    color: NoorColors.cream,
                    borderRadius: BorderRadius.circular(NoorRadius.heroCard),
                  ),
                  child: Column(children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(NoorRadius.heroCard)),
                      // The arch art's own aspect (Phase 11b): the
                      // fixed 190 height cropped the arch apex and
                      // sides; now the whole arch sits in its box.
                      child: AspectRatio(
                          aspectRatio: 417 / 255,
                          child: Image.asset(NoorAssets.playerArch,
                              cacheWidth: 1170,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  height: 190, color: NoorColors.cream))),
                    ),
                    Text(_surahTitle,
                        style: NoorType.screenTitle),
                    const SizedBox(height: 3),
                    Text(
                        _live
                            ? '$_surahMeaning  •  Ayah ${_ayahIndex + 1}'
                            : _surahMeaning,
                        style: NoorType.meta),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(children: [
                        Expanded(child: _Stat('Ayah', '1 – $_ayahCount')),
                        Expanded(child: _Stat('Juz', _juzLabel)),
                        Expanded(child: _Stat('Page', _pageLabel)),
                      ]),
                    ),
                    const SizedBox(height: 18),
                  ]),
                ),
                const SizedBox(height: 16),
                // Reciter row
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(NoorRadius.card)),
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: NoorColors.cream,
                      backgroundImage: AssetImage(NoorAssets.reciterAvatar),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reciter',
                                style: NoorType.meta.copyWith(color: Colors.white60)),
                            Text(SampleData.playerReciter,
                                style: NoorType.body.copyWith(color: Colors.white)),
                          ]),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ]),
                ),
                const SizedBox(height: 14),
                // Seek
                Row(children: [
                  Text(
                      _playerReady
                          ? _fmt(_position)
                          : SampleData.playerPosition,
                      style: NoorType.tabular(NoorType.meta.copyWith(color: Colors.white70))),
                  Expanded(
                    child: Slider(
                      value: _seek.clamp(
                          0,
                          (_playerReady && _duration.inSeconds > 0
                                  ? _duration.inSeconds
                                  : 2096)
                              .toDouble()),
                      min: 0,
                      max: (_playerReady && _duration.inSeconds > 0
                              ? _duration.inSeconds
                              : 2096)
                          .toDouble(),
                      activeColor: Colors.white,
                      inactiveColor: Colors.white24,
                      onChanged: (v) {
                        setState(() => _seek = v);
                        if (_playerReady) {
                          _player.seek(Duration(seconds: v.round()));
                        }
                      },
                    ),
                  ),
                  Text(
                      _playerReady
                          ? _fmt(_duration)
                          : SampleData.playerDuration,
                      style: NoorType.tabular(NoorType.meta.copyWith(color: Colors.white70))),
                ]),
                // Transport
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _transport(Icons.repeat, 'Repeat', false),
                    IconButton(
                        icon: const Icon(Icons.skip_previous,
                            color: Colors.white, size: 28),
                        onPressed: () => _skip(-1)),
                    Container(
                      width: 62,
                      height: 62,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                      child: IconButton(
                        icon: Icon(_playing ? Icons.pause : Icons.play_arrow,
                            color: NoorColors.emeraldDark, size: 30),
                        onPressed: _togglePlay,
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.skip_next,
                            color: Colors.white, size: 28),
                        onPressed: () => _skip(1)),
                    _transport(
                        Icons.repeat_one, 'Repeat\nAyah', _repeatMode == 1),
                  ],
                ),
                const SizedBox(height: 16),
                // Cream controls panel
                Container(
                  decoration: BoxDecoration(
                      color: NoorColors.cream,
                      borderRadius: BorderRadius.circular(NoorRadius.heroCard)),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Semantics(
                                button: true,
                                label: 'Playback speed',
                                child: InkWell(
                                    onTap: _cycleSpeed,
                                    borderRadius: BorderRadius.circular(12),
                                    child: _action('${_speed}x', 'Speed'))),
                            _actionIcon(Icons.timer_outlined, 'Timer',
                                soon: true),
                            _actionIcon(Icons.nightlight_outlined, 'Sleep',
                                soon: true),
                            _actionIcon(Icons.download_outlined, 'Download',
                                soon: true),
                            _actionIcon(Icons.share_outlined, 'Share',
                                soon: true),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('Playback Range',
                            style: NoorType.body),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                              child: _rangeChip('Surah (1 – $_ayahCount)', true)),
                          const SizedBox(width: 10),
                          Expanded(child: _rangeChip('Ayah Range', false)),
                        ]),
                        const SizedBox(height: 18),
                        const Text('Repetition Settings',
                            style: NoorType.body),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                              child: _stepper(
                            'Repeat',
                            'How many times',
                            '$_repeat',
                            () => setState(
                                () => _repeat = (_repeat - 1).clamp(1, 10)),
                            () => setState(
                                () => _repeat = (_repeat + 1).clamp(1, 10)),
                          )),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _stepper(
                            'Pause',
                            'Gap between repeats',
                            '$_pauseSec sec',
                            () => setState(
                                () => _pauseSec = (_pauseSec - 1).clamp(0, 10)),
                            () => setState(
                                () => _pauseSec = (_pauseSec + 1).clamp(0, 10)),
                          )),
                        ]),
                        const SizedBox(height: 18),
                        Row(children: [
                          const Expanded(
                              child: Text('Up Next',
                                  style: NoorType.body)),
                          const Text('Autoplay',
                              style: NoorType.meta),
                          Semantics(
                              label: 'Autoplay',
                              toggled: _autoplay,
                              child: Switch(
                                  value: _autoplay,
                                  activeThumbColor: NoorColors.emerald,
                                  onChanged: (v) =>
                                      setState(() => _autoplay = v))),
                        ]),
                        _upNext(
                            _upNextA?.$1 ?? '19',
                            _upNextA?.$2 ?? 'Surah Maryam',
                            _upNextA?.$3 ?? 'Juz 16  •  Page 305',
                            _upNextA?.$4 ?? '98 Ayahs'),
                        const Divider(color: NoorColors.hairline),
                        _upNext(
                            _upNextB?.$1 ?? '20',
                            _upNextB?.$2 ?? 'Surah Taha',
                            _upNextB?.$3 ?? 'Juz 16  •  Page 312',
                            _upNextB?.$4 ?? '135 Ayahs'),
                      ]),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _transport(IconData icon, String label, bool active) => Semantics(
      button: true,
      selected: active,
      label: label.replaceAll('\n', ' '),
      child: InkWell(
        onTap: () async {
          final next = active ? 0 : 1;
          setState(() => _repeatMode = next);
          if (_playerReady) {
            await _player.setLoopMode(next == 1 ? LoopMode.one : LoopMode.off);
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 48,
          height: 62,
          child: Column(children: [
            Icon(icon,
                color: active ? NoorColors.gold : Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: NoorType.meta.copyWith(color: active ? NoorColors.gold : Colors.white70)),
          ]),
        ),
      ));

  Widget _action(String glyph, String label) => Column(children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NoorColors.hairline)),
          child: Text(glyph,
              style: NoorType.secondary.copyWith(color: NoorColors.emeraldDark)),
        ),
        const SizedBox(height: 6),
        Text(label, style: NoorType.meta),
      ]);

  Widget _actionIcon(IconData icon, String label, {bool soon = false}) =>
      Semantics(
          enabled: !soon,
          label: soon ? '$label — coming soon' : label,
          child: Column(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NoorColors.hairline)),
              child: Icon(icon, color: NoorColors.emeraldDark, size: 21),
            ),
            const SizedBox(height: 6),
            Text(label, style: NoorType.meta),
            if (soon)
              Text('Soon',
                  style: NoorType.meta.copyWith(color: NoorColors.mutedDark)),
          ]));

  Widget _rangeChip(String label, bool on) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? NoorColors.emeraldDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: on ? null : Border.all(color: NoorColors.hairline),
        ),
        child: Text(label,
            style: NoorType.secondary.copyWith(color: on ? Colors.white : NoorColors.ink)),
      );

  Widget _stepper(String title, String sub, String value, VoidCallback minus,
          VoidCallback plus) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style:
                NoorType.secondary),
        Text(sub,
            style: NoorType.meta.copyWith(color: NoorColors.muted)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NoorColors.hairline)),
          child: Row(children: [
            IconButton(
                icon: const Icon(Icons.remove, size: 17), onPressed: minus),
            Expanded(
                child: Text(value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700))),
            IconButton(icon: const Icon(Icons.add, size: 17), onPressed: plus),
          ]),
        ),
      ]);

  /// Up Next row. Tapping it opens that surah in the player
  /// (pushReplacement, so Back returns to where you came from).
  /// The tap target is invisible — the row looks exactly as drawn.
  Widget _upNext(String n, String title, String meta, String ayahs) {
    final target = int.tryParse(n);
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: NoorColors.emeraldSoft, shape: BoxShape.circle),
          child: Text(n,
              style: NoorType.meta.copyWith(color: NoorColors.emeraldDark)),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(meta,
                  style: NoorType.meta.copyWith(color: NoorColors.muted)),
            ])),
        Text(ayahs,
            style: NoorType.meta.copyWith(color: NoorColors.muted)),
        const Icon(Icons.more_vert, size: 18, color: NoorColors.muted),
      ]),
    );
    if (target == null || target == widget.surah) return row;
    return Semantics(
      button: true,
      label: 'Play $title',
      child: InkWell(
        onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => QuranAudioPlayerScreen(surah: target))),
        child: row,
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(label,
            style: NoorType.meta.copyWith(color: NoorColors.muted)),
        const SizedBox(height: 4),
        Text(value,
            style: NoorType.body),
      ]);
}
