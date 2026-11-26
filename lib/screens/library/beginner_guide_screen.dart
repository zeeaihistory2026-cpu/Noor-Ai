import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/lifestyle_guides_data.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import '../worship/salah_guide_screen.dart';

/// Module 18 P2 — New Muslim & Beginner Mode:
/// 30-day interactive roadmap, beginner Salah starter, and A-Z Islamic glossary.
class BeginnerGuideScreen extends StatefulWidget {
  const BeginnerGuideScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<BeginnerGuideScreen> createState() => _BeginnerGuideScreenState();
}

class _BeginnerGuideScreenState extends State<BeginnerGuideScreen> {
  late int _tab;
  Set<int> _doneIds = <int>{};
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 2);
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final ids = await NoorStore.getBeginnerRoadmapDone();
    if (!mounted) return;
    setState(() => _doneIds = ids.toSet());
  }

  void _toggleMilestone(int id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_doneIds.contains(id)) {
        _doneIds.remove(id);
      } else {
        _doneIds.add(id);
      }
    });
    NoorStore.setBeginnerRoadmapDone(_doneIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            NoorDarkHeader(
              title: 'Beginner & New Muslim',
              subtitle: '30-day roadmap, basics & glossary',
              child: NoorPillTabs(
                tabs: const ['30-Day Path', 'Start Salah', 'Glossary'],
                selected: _tab,
                onSelect: (i) => setState(() => _tab = i),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _buildRoadmapTab(),
                  _buildStartSalahTab(),
                  _buildGlossaryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadmapTab() {
    final total = LifestyleGuidesData.beginnerRoadmap.length;
    final done = _doneIds.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        NoorCard(
          color: NoorColors.emeraldDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '30-DAY BEGINNER JOURNEY',
                style: NoorType.eyebrow.copyWith(color: NoorColors.onEmeraldMuted),
              ),
              const SizedBox(height: 6),
              Text(
                '$done of $total milestones completed',
                style: NoorType.tabular(
                    NoorType.section.copyWith(color: NoorColors.gold)),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: total == 0 ? 0 : done / total,
                  color: NoorColors.gold,
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final m in LifestyleGuidesData.beginnerRoadmap) ...[
          NoorCard(
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: NoorColors.emeraldDark,
              value: _doneIds.contains(m.id),
              onChanged: (_) => _toggleMilestone(m.id),
              title: Text(m.title, style: NoorType.cardTitle),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(m.week,
                      style: NoorType.eyebrow
                          .copyWith(color: NoorTheme.accent(context))),
                  const SizedBox(height: 3),
                  Text(m.detail,
                      style: NoorType.secondary
                          .copyWith(color: NoorTheme.muted(context))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildStartSalahTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        NoorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NoorSectionLabel('Essential Words to Begin Praying'),
              const SizedBox(height: 8),
              const Text(
                'Start gently: focus on Allahu Akbar, Al-Fatihah (in your language alongside Arabic while learning), Subhana Rabbiyal-Azim (Ruku), and Subhana Rabbiyal-A’la (Sujud).',
                style: NoorType.body,
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NoorTheme.softSurface(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا رَسُولُ اللَّهِ',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: NoorType.arabic(
                        size: 21,
                        color: NoorTheme.foreground(context,
                            light: NoorColors.emeraldDark),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ash-hadu an la ilaha illallah wa ash-hadu anna Muhammadan Rasulullah',
                      textAlign: TextAlign.center,
                      style: NoorType.secondary.copyWith(
                        fontStyle: FontStyle.italic,
                        color: NoorTheme.muted(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SalahGuideScreen()),
                  ),
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Open Step-by-Step Salah & Wudu Guide'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlossaryTab() {
    final q = _searchCtrl.text.trim().toLowerCase();
    final items = LifestyleGuidesData.glossary.where((g) {
      if (q.isEmpty) return true;
      return g.term.toLowerCase().contains(q) ||
          g.definition.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search Islamic terms (e.g. Wudu, Sunnah, Tawakkul)...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: NoorTheme.surface(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: NoorTheme.border(context)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (final g in items) ...[
          NoorCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.term, style: NoorType.cardTitle),
                      const SizedBox(height: 4),
                      Text(g.definition,
                          style: NoorType.secondary
                              .copyWith(color: NoorTheme.muted(context))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  g.arabic,
                  textDirection: TextDirection.rtl,
                  style: NoorType.arabic(
                    size: 22,
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
}

