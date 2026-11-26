import 'package:flutter/material.dart';
import '../data/noor_store.dart';
import '../data/offline_quran.dart';
import '../data/quran_service.dart';
import '../screens/quran/quran_reader_screen.dart';
import '../theme/noor_theme.dart';
import 'noor_components.dart';

class QuranResumeCard extends StatefulWidget {
  const QuranResumeCard({super.key, this.compact = false});
  final bool compact;

  @override
  State<QuranResumeCard> createState() => _QuranResumeCardState();
}

class _QuranResumeCardState extends State<QuranResumeCard> {
  (int, int)? _position;
  String _name = 'Al-Fatihah';
  int _count = 7;

  @override
  void initState() {
    super.initState();
    _load();
    NoorStore.progressRevision.addListener(_load);
  }

  @override
  void dispose() {
    NoorStore.progressRevision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final position = await NoorStore.getReadingPosition();
    if (!mounted) return;
    if (position == null) {
      setState(() => _position = null);
      return;
    }
    try {
      final surah =
          await OfflineQuran.surah(position.$1, QuranService.editionArabic);
      if (!mounted) return;
      setState(() {
        _position = position;
        _name = surah['englishName'] as String;
        _count = (surah['ayahs'] as List).length;
      });
    } catch (_) {/* Keep the start-reading action available. */}
  }

  Future<void> _open() async {
    final position = _position ?? (1, 1);
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            QuranReaderScreen(surah: position.$1, initialAyah: position.$2)));
    await _load();
  }

  @override
  Widget build(BuildContext context) => widget.compact
      ? NoorCard(
          key: const ValueKey('home-continue-quran'),
          radius: 18,
          padding: const EdgeInsets.all(16),
          onTap: _open,
          child: Row(children: [
            Icon(Icons.menu_book_outlined,
                size: 25, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
                      _position == null
                          ? 'Start reading Quran'
                          : 'Continue Quran',
                      style:
                          NoorType.body.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                      _position == null
                          ? 'Begin with Al-Fatihah'
                          : '$_name · Ayah ${_position!.$2}',
                      style: NoorType.meta)
                ])),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 21),
          ]),
        )
      : NoorCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            NoorSectionLabel(
                _position == null ? 'Read Quran' : 'Continue Quran'),
            const SizedBox(height: 10),
            Text(_position == null ? 'Al-Fatihah' : _name,
                style: NoorType.screenTitle),
            const SizedBox(height: 6),
            Text(
                _position == null
                    ? 'Begin with the opening surah'
                    : 'Last opened: Ayah ${_position!.$2} of $_count',
                style: NoorType.meta),
            const SizedBox(height: 14),
            SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                    onPressed: _open,
                    icon: const Icon(Icons.menu_book),
                    label: Text(_position == null
                        ? 'Start Reading'
                        : 'Continue Reading'))),
          ]),
        );
}
