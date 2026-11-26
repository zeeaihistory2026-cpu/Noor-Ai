import 'package:flutter/material.dart';
import '../../data/islamic_academy_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Module 08 P1/P2 — Islamic Academy:
/// Five Pillars of Islam, Six Pillars of Faith (Iman),
/// Searchable 99 Names of Allah, and Knowledge Quiz.
class IslamicAcademyScreen extends StatefulWidget {
  const IslamicAcademyScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<IslamicAcademyScreen> createState() => _IslamicAcademyScreenState();
}

class _IslamicAcademyScreenState extends State<IslamicAcademyScreen> {
  late int _tab;
  String _nameQuery = '';
  int _quizIndex = 0;
  int? _selectedOption;
  int _score = 0;
  bool _quizFinished = false;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 3);
  }

  void _selectAnswer(int idx) {
    if (_selectedOption != null) return;
    final q = IslamicAcademyData.academyQuizzes[_quizIndex];
    setState(() {
      _selectedOption = idx;
      if (idx == q.correctIndex) _score++;
    });
  }

  void _nextQuestion() {
    if (_quizIndex + 1 >= IslamicAcademyData.academyQuizzes.length) {
      setState(() => _quizFinished = true);
    } else {
      setState(() {
        _quizIndex++;
        _selectedOption = null;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _quizIndex = 0;
      _selectedOption = null;
      _score = 0;
      _quizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            NoorDarkHeader(
              title: 'Islamic Academy',
              subtitle: 'Foundations, Asma ul Husna & quizzes',
              child: NoorPillTabs(
                tabs: const ['Islam', 'Iman', '99 Names', 'Quiz'],
                selected: _tab,
                onSelect: (i) => setState(() => _tab = i),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _buildPillars(
                    'Five Pillars of Islam',
                    'The core acts of worship upon which Islamic practice stands.',
                    IslamicAcademyData.fivePillars,
                  ),
                  _buildPillars(
                    'Six Pillars of Iman (Faith)',
                    'The foundational beliefs affirmed in the Hadith of Jibreel.',
                    IslamicAcademyData.sixPillarsOfIman,
                  ),
                  _buildNamesOfAllah(),
                  _buildQuiz(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillars(
      String heading, String subtitle, List<PillarItem> items) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Semantics(header: true, child: Text(heading, style: NoorType.section)),
        const SizedBox(height: 6),
        Text(subtitle,
            style: NoorType.secondary.copyWith(color: NoorTheme.muted(context))),
        const SizedBox(height: 16),
        for (final p in items) ...[
          NoorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NoorRosetteBadge(p.number, size: 34),
                    const SizedBox(width: 12),
                    Expanded(child: Text(p.title, style: NoorType.cardTitle)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: NoorTheme.softSurface(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    p.arabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: NoorType.arabic(
                      size: 21,
                      color: NoorTheme.foreground(context,
                          light: NoorColors.emeraldDark),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(p.summary, style: NoorType.body),
                const SizedBox(height: 8),
                Text(p.reference,
                    style: NoorType.meta
                        .copyWith(color: NoorTheme.accent(context))),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildNamesOfAllah() {
    final q = _nameQuery.trim().toLowerCase();
    final filtered = IslamicAcademyData.namesOfAllah.where((n) {
      if (q.isEmpty) return true;
      return n.transliteration.toLowerCase().contains(q) ||
          n.meaning.toLowerCase().contains(q) ||
          n.arabic.contains(_nameQuery.trim()) ||
          '${n.number}' == q;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        TextField(
          onChanged: (v) => setState(() => _nameQuery = v),
          decoration: InputDecoration(
            hintText: 'Search 99 Names by name, meaning or number...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: NoorTheme.surface(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: NoorTheme.border(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: NoorTheme.border(context)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (final n in filtered) ...[
          NoorCard(
            child: Row(
              children: [
                NoorRosetteBadge(n.number, filled: false, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.transliteration, style: NoorType.cardTitle),
                      const SizedBox(height: 2),
                      Text(n.meaning,
                          style: NoorType.meta
                              .copyWith(color: NoorTheme.muted(context))),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  n.arabic,
                  textDirection: TextDirection.rtl,
                  style: NoorType.arabic(
                    size: 24,
                    color: NoorTheme.accent(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildQuiz() {
    if (_quizFinished) {
      final total = IslamicAcademyData.academyQuizzes.length;
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        children: [
          NoorCard(
            color: NoorColors.emeraldDark,
            child: Column(
              children: [
                Text('QUIZ COMPLETE',
                    style: NoorType.eyebrow
                        .copyWith(color: NoorColors.onEmeraldMuted)),
                const SizedBox(height: 12),
                Text(
                  '$_score / $total',
                  style: NoorType.tabular(
                      NoorType.hero(size: 40, color: NoorColors.gold)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review the Pillars and Guides tabs anytime to strengthen your knowledge.',
                  textAlign: TextAlign.center,
                  style: NoorType.secondary
                      .copyWith(color: NoorColors.onEmeraldMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _restartQuiz,
            icon: const Icon(Icons.refresh),
            label: const Text('Retake Quiz'),
          ),
        ],
      );
    }

    final q = IslamicAcademyData.academyQuizzes[_quizIndex];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(q.topic.toUpperCase(),
                style: NoorType.eyebrow
                    .copyWith(color: NoorTheme.accent(context))),
            Text(
              'Question ${_quizIndex + 1} of ${IslamicAcademyData.academyQuizzes.length}',
              style: NoorType.tabular(
                  NoorType.meta.copyWith(color: NoorTheme.muted(context))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        NoorCard(
          child: Text(q.prompt, style: NoorType.section),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < q.options.length; i++) ...[
          NoorOptionTile(
            label: q.options[i],
            selected: _selectedOption == i,
            trailing: _selectedOption == null
                ? null
                : Icon(
                    i == q.correctIndex
                        ? Icons.check_circle
                        : (_selectedOption == i
                            ? Icons.cancel
                            : Icons.circle_outlined),
                    color: _selectedOption == i
                        ? Colors.white
                        : NoorTheme.accent(context),
                  ),
            onTap: () => _selectAnswer(i),
          ),
          const SizedBox(height: 10),
        ],
        if (_selectedOption != null) ...[
          const SizedBox(height: 6),
          NoorCard(
            color: NoorTheme.softSurface(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedOption == q.correctIndex
                      ? 'Correct'
                      : 'Review Note',
                  style: NoorType.cardTitle
                      .copyWith(color: NoorTheme.accent(context)),
                ),
                const SizedBox(height: 4),
                Text(q.explanation, style: NoorType.body),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _nextQuestion,
            child: Text(
              _quizIndex + 1 >= IslamicAcademyData.academyQuizzes.length
                  ? 'View Score'
                  : 'Next Question',
            ),
          ),
        ],
      ],
    );
  }
}

