import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/lifestyle_guides_data.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../quran/quran_reader_screen.dart';

/// Module 17 P3 — Kids Islamic Learning:
/// Interactive Arabic Alphabet grid, Short Surah memorization checklist,
/// everyday prophetic Adab (manners), and a playful self-check quiz.
class KidsCornerScreen extends StatefulWidget {
  const KidsCornerScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<KidsCornerScreen> createState() => _KidsCornerScreenState();
}

class _KidsCornerScreenState extends State<KidsCornerScreen> {
  late int _tab;
  int _selectedLetter = 0;
  Set<String> _completedSurahs = <String>{};
  int _quizIndex = 0;
  int? _pickedOption;
  int _quizScore = 0;
  int _bestQuizScore = 0;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 2);
    _load();
  }

  Future<void> _load() async {
    final surahs = await NoorStore.getKidsCompletedSurahs();
    final best = await NoorStore.getKidsQuizBest();
    if (!mounted) return;
    setState(() {
      _completedSurahs = surahs.toSet();
      _bestQuizScore = best;
    });
  }

  void _toggleSurah(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_completedSurahs.contains(key)) {
        _completedSurahs.remove(key);
      } else {
        _completedSurahs.add(key);
      }
    });
    NoorStore.setKidsCompletedSurahs(_completedSurahs.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            NoorDarkHeader(
              title: 'Kids Islamic Corner',
              subtitle: 'Arabic alphabet, short Surahs & manners',
              child: NoorPillTabs(
                tabs: const ['Alphabet', 'Surahs', 'Manners & Quiz'],
                selected: _tab,
                onSelect: (i) => setState(() => _tab = i),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _buildAlphabetTab(),
                  _buildSurahsTab(),
                  _buildMannersAndQuizTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlphabetTab() {
    final active = LifestyleGuidesData.arabicAlphabet[_selectedLetter];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        NoorCard(
          color: NoorColors.emeraldDark,
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: NoorColors.gold),
                ),
                child: Text(
                  active.letter,
                  textDirection: TextDirection.rtl,
                  style: NoorType.arabic(size: 36, color: NoorColors.gold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(active.name,
                        style: NoorType.section.copyWith(color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('Sound: "${active.sound}"',
                        style: NoorType.secondary
                            .copyWith(color: NoorColors.onEmeraldMuted)),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          active.exampleArabic,
                          textDirection: TextDirection.rtl,
                          style: NoorType.arabic(size: 20, color: NoorColors.gold)
                              .copyWith(height: 1.4),
                        ),
                        Text(
                          '— ${active.exampleMeaning}',
                          style: NoorType.secondary
                              .copyWith(color: NoorColors.gold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: LifestyleGuidesData.arabicAlphabet.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 3 : 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, idx) {
            final item = LifestyleGuidesData.arabicAlphabet[idx];
            final on = idx == _selectedLetter;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Semantics(
              button: true,
              selected: on,
              label: '${item.name} letter ${item.letter}',
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedLetter = idx);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: on
                        ? (isDark
                            ? NoorColors.darkGold
                            : NoorColors.emeraldDark)
                        : NoorTheme.surface(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: NoorTheme.border(context)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.letter,
                        textDirection: TextDirection.rtl,
                        style: NoorType.arabic(
                          size: 22,
                          color: on
                              ? (isDark ? NoorColors.darkBg : Colors.white)
                              : NoorTheme.accent(context),
                        ).copyWith(height: 1.4),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: NoorType.meta.copyWith(
                          color: on
                              ? (isDark ? NoorColors.darkBg : Colors.white)
                              : NoorTheme.muted(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSurahsTab() {
    final stars = _completedSurahs.length;
    final total = LifestyleGuidesData.kidsSurahs.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        NoorCard(
          color: NoorColors.emeraldDark,
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: NoorColors.gold, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SHORT SURAH STARS',
                      style: NoorType.eyebrow
                          .copyWith(color: NoorColors.onEmeraldMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$stars of $total Surahs learned',
                      style: NoorType.tabular(
                          NoorType.section.copyWith(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final s in LifestyleGuidesData.kidsSurahs) ...[
          NoorCard(
            child: Row(
              children: [
                Checkbox(
                  activeColor: NoorColors.emeraldDark,
                  value: _completedSurahs.contains('${s.surah}'),
                  onChanged: (_) => _toggleSurah('${s.surah}'),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${s.name} (${s.ayahs})', style: NoorType.cardTitle),
                      const SizedBox(height: 2),
                      Text(s.focus,
                          style: NoorType.meta
                              .copyWith(color: NoorTheme.muted(context))),
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    foregroundColor: NoorTheme.accent(context),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => QuranReaderScreen(surah: s.surah),
                    ),
                  ),
                  child: const Text('Read'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildMannersAndQuizTab() {
    const questions = LifestyleGuidesData.kidsQuizzes;
    final q = questions[_quizIndex];
    final answered = _pickedOption != null;
    final isLast = _quizIndex == questions.length - 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Semantics(
          header: true,
          child: const Text('Everyday Islamic Manners (Adab)',
              style: NoorType.section),
        ),
        const SizedBox(height: 10),
        for (final m in LifestyleGuidesData.kidsManners) ...[
          NoorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title, style: NoorType.cardTitle),
                const SizedBox(height: 4),
                Text(m.phrase,
                    style: NoorType.meta
                        .copyWith(color: NoorTheme.accent(context))),
                const SizedBox(height: 4),
                Text(m.detail, style: NoorType.secondary),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: const Text('Kids Mini Quiz', style: NoorType.section),
              ),
            ),
            Text('Best: $_bestQuizScore / ${questions.length}',
                style: NoorType.tabular(
                    NoorType.meta.copyWith(color: NoorTheme.accent(context)))),
          ],
        ),
        const SizedBox(height: 10),
        NoorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Question ${_quizIndex + 1} of ${questions.length}',
                  style: NoorType.eyebrow
                      .copyWith(color: NoorTheme.accent(context))),
              const SizedBox(height: 8),
              Text(q.prompt, style: NoorType.cardTitle),
              const SizedBox(height: 12),
              for (var i = 0; i < q.options.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                NoorOptionTile(
                  label: q.options[i],
                  selected: _pickedOption == i,
                  onTap: () {
                    if (answered) return;
                    HapticFeedback.selectionClick();
                    final nextScore =
                        i == q.correctIndex ? _quizScore + 1 : _quizScore;
                    setState(() {
                      _pickedOption = i;
                      _quizScore = nextScore;
                    });
                    if (isLast) NoorStore.setKidsQuizBest(nextScore);
                  },
                ),
              ],
              if (answered) ...[
                const SizedBox(height: 12),
                Text(q.explanation, style: NoorType.secondary),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style:
                        FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                    onPressed: () {
                      setState(() {
                        if (isLast) {
                          _quizIndex = 0;
                          _quizScore = 0;
                        } else {
                          _quizIndex++;
                        }
                        _pickedOption = null;
                      });
                      _load();
                    },
                    child: Text(isLast ? 'Play Again' : 'Next Question'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

