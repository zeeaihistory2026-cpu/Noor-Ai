import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/islamic_academy_data.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Module 13 P1/P2 — Hajj & Umrah Guide:
/// Umrah steps, Hajj days overview, Ihram permitted/prohibited guidance,
/// pilgrimage packing checklist, and persisted 7-circuit Tawaf & Sa'i counters.
class HajjUmrahScreen extends StatefulWidget {
  const HajjUmrahScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<HajjUmrahScreen> createState() => _HajjUmrahScreenState();
}

class _HajjUmrahScreenState extends State<HajjUmrahScreen> {
  late int _tab;
  int _tawaf = 0;
  int _sai = 0;
  Set<String> _packedIds = <String>{};

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 2);
    _loadState();
  }

  Future<void> _loadState() async {
    final t = await NoorStore.getHajjTawafCount();
    final s = await NoorStore.getHajjSaiCount();
    final packed = await NoorStore.getHajjChecklistDone();
    if (!mounted) return;
    setState(() {
      _tawaf = t;
      _sai = s;
      _packedIds = packed.toSet();
    });
  }

  void _stepCounter(bool isTawaf, int nextValue) {
    HapticFeedback.selectionClick();
    final clamped = nextValue.clamp(0, 7);
    setState(() {
      if (isTawaf) {
        _tawaf = clamped;
      } else {
        _sai = clamped;
      }
    });
    if (isTawaf) {
      NoorStore.setHajjTawafCount(clamped);
    } else {
      NoorStore.setHajjSaiCount(clamped);
    }
  }

  void _togglePacked(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_packedIds.contains(id)) {
        _packedIds.remove(id);
      } else {
        _packedIds.add(id);
      }
    });
    NoorStore.setHajjChecklistDone(_packedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            NoorDarkHeader(
              title: 'Hajj & Umrah',
              subtitle: 'Step-by-step pilgrimage guide & counters',
              child: NoorPillTabs(
                tabs: const ['Umrah', 'Hajj', 'Tawaf & Ihram'],
                selected: _tab,
                onSelect: (i) => setState(() => _tab = i),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _buildGuide(
                    'Umrah Step-by-Step',
                    'Follow the prophetic sequence from Ihram to Halq/Taqsir.',
                    IslamicAcademyData.umrahSteps,
                  ),
                  _buildGuide(
                    'Hajj Days Overview (8–13 Dhul-Hijjah)',
                    'Key stations and obligations of Hajj.',
                    IslamicAcademyData.hajjDays,
                  ),
                  _buildCountersAndIhram(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuide(String title, String sub, List<GuideStep> steps) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Semantics(header: true, child: Text(title, style: NoorType.section)),
        const SizedBox(height: 6),
        Text(sub,
            style: NoorType.secondary.copyWith(color: NoorTheme.muted(context))),
        const SizedBox(height: 16),
        for (final step in steps) ...[
          NoorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NoorRosetteBadge(step.step, size: 34),
                    const SizedBox(width: 12),
                    Expanded(child: Text(step.title, style: NoorType.cardTitle)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(step.detail, style: NoorType.body),
                if (step.arabic != null) ...[
                  const SizedBox(height: 12),
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
                          step.arabic!,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: NoorType.arabic(
                            size: 20,
                            color: NoorTheme.foreground(context,
                                light: NoorColors.emeraldDark),
                          ),
                        ),
                        if (step.transliteration != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            step.transliteration!,
                            textAlign: TextAlign.center,
                            style: NoorType.secondary.copyWith(
                              fontStyle: FontStyle.italic,
                              color: NoorTheme.muted(context),
                            ),
                          ),
                        ],
                        if (step.translation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            step.translation!,
                            textAlign: TextAlign.center,
                            style: NoorType.meta
                                .copyWith(color: NoorTheme.muted(context)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (step.reference != null) ...[
                  const SizedBox(height: 8),
                  Text(step.reference!,
                      style: NoorType.meta
                          .copyWith(color: NoorTheme.accent(context))),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  String _tawafCue(int count) {
    if (count == 0) {
      return 'Begin facing Hajar al-Aswad (Black Stone) with Kaaba on your left. Say Bismillahi Allahu Akbar.';
    }
    if (count <= 3) {
      return 'Circuit $count of 7: Brisk pace (Raml) for men in rounds 1–3. Between Rukn al-Yamani & Black Stone recite: “Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina ‘adhaban-nar.”';
    }
    if (count < 7) {
      return 'Circuit $count of 7: Walk steadily in Dhikr and personal Dua (Quran 2:201 at the Yemeni-to-Black Stone corner).';
    }
    return '7/7 Circuits complete! Cover right shoulder, pray 2 rak’ah behind Maqam Ibrahim if clear, and drink Zamzam water.';
  }

  String _saiCue(int count) {
    if (count == 0) {
      return 'Ascend Safa hill, face the Kaaba, raise hands in Dua, and start Lap 1 walking toward Marwah.';
    }
    if (count == 7) {
      return '7/7 Laps complete at Marwah! Proceed to Halq (shave head) or Taqsir (trim hair) to exit Umrah Ihram.';
    }
    final isOdd = count.isOdd;
    return isOdd
        ? 'Lap $count of 7 (Safa → Marwah): Jog lightly between the green lights (men) while keeping sincere Dua.'
        : 'Lap $count of 7 (Marwah → Safa): Walk calmly in remembrance; pause facing the Kaaba for Dua at each hill.';
  }

  Widget _buildCountersAndIhram() {
    final packedCount = _packedIds.length;
    final totalChecklist = IslamicAcademyData.pilgrimageChecklist.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        _counterCard(
          isTawaf: true,
          title: 'Tawaf Counter',
          subtitle: '7 counter-clockwise circuits around the Kaaba',
          count: _tawaf,
          unit: 'Circuit',
          cueText: _tawafCue(_tawaf),
        ),
        const SizedBox(height: 14),
        _counterCard(
          isTawaf: false,
          title: 'Sa’i Counter',
          subtitle: '7 laps between Safa and Marwah (ends at Marwah)',
          count: _sai,
          unit: 'Lap',
          cueText: _saiCue(_sai),
        ),
        const SizedBox(height: 16),
        NoorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: const NoorSectionLabel('Pilgrimage Packing Checklist'),
                    ),
                  ),
                  Text(
                    '$packedCount / $totalChecklist',
                    style: NoorType.tabular(NoorType.meta.copyWith(
                      color: NoorTheme.accent(context),
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Essential non-scented Ihram & Haram items saved on this device.',
                style: NoorType.meta.copyWith(color: NoorTheme.muted(context)),
              ),
              const SizedBox(height: 10),
              for (var i = 0;
                  i < IslamicAcademyData.pilgrimageChecklist.length;
                  i++) ...[
                if (i > 0)
                  Divider(height: 1, color: NoorTheme.border(context)),
                Builder(builder: (context) {
                  final item = IslamicAcademyData.pilgrimageChecklist[i];
                  final checked = _packedIds.contains(item.id);
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: false,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: NoorColors.emeraldDark,
                    value: checked,
                    onChanged: (_) => _togglePacked(item.id),
                    title: Text(
                      item.title,
                      style: NoorType.secondary.copyWith(
                        decoration:
                            checked ? TextDecoration.lineThrough : null,
                        color: checked
                            ? NoorTheme.muted(context)
                            : NoorTheme.foreground(context),
                      ),
                    ),
                    subtitle: Text(
                      item.note,
                      style: NoorType.meta
                          .copyWith(color: NoorTheme.muted(context)),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        NoorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: const NoorSectionLabel('Ihram Permitted & Prohibited'),
              ),
              const SizedBox(height: 12),
              Text(
                'PROHIBITED WHILE IN IHRAM',
                style: NoorType.eyebrow.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? NoorColors.errorOnDark
                        : NoorColors.error),
              ),
              const SizedBox(height: 8),
              for (var i = 0;
                  i < IslamicAcademyData.ihramProhibitions.length;
                  i++) ...[
                if (i > 0) const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.block_outlined,
                        size: 18,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? NoorColors.errorOnDark
                            : NoorColors.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(IslamicAcademyData.ihramProhibitions[i],
                          style: NoorType.body),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Divider(height: 1, color: NoorTheme.border(context)),
              const SizedBox(height: 12),
              Text(
                'PERMITTED IN IHRAM',
                style: NoorType.eyebrow
                    .copyWith(color: NoorTheme.accent(context)),
              ),
              const SizedBox(height: 8),
              for (var i = 0;
                  i < IslamicAcademyData.ihramAllowed.length;
                  i++) ...[
                if (i > 0) const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 18, color: NoorTheme.accent(context)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(IslamicAcademyData.ihramAllowed[i],
                          style: NoorType.body),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _counterCard({
    required bool isTawaf,
    required String title,
    required String subtitle,
    required int count,
    required String unit,
    required String cueText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final done = count >= 7;
    return NoorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: done
                      ? NoorColors.emeraldDark
                      : NoorTheme.softSurface(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isTawaf ? Icons.sync : Icons.directions_walk,
                  color: done
                      ? NoorColors.gold
                      : NoorTheme.accent(context),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: NoorType.cardTitle),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: NoorType.meta
                            .copyWith(color: NoorTheme.muted(context))),
                  ],
                ),
              ),
              TextButton(
                onPressed: count > 0 ? () => _stepCounter(isTawaf, 0) : null,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: NoorTheme.accent(context),
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 7-circuit interactive visual stepper
          Row(
            children: [
              for (var step = 1; step <= 7; step++) ...[
                if (step > 1) const SizedBox(width: 6),
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: step == count,
                    label: 'Set $unit $step of 7',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _stepCounter(isTawaf, step),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: step <= count
                              ? (isDark
                                  ? NoorColors.darkGold
                                  : NoorColors.emeraldDark)
                              : NoorTheme.softSurface(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: step == count + 1
                                ? NoorTheme.accent(context)
                                : NoorTheme.border(context),
                            width: step == count + 1 ? 1.6 : 1,
                          ),
                        ),
                        child: Text(
                          '$step',
                          style: NoorType.tabular(NoorType.meta.copyWith(
                            fontWeight: FontWeight.w700,
                            color: step <= count
                                ? (isDark ? NoorColors.darkBg : Colors.white)
                                : NoorTheme.foreground(context),
                          )),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: NoorTheme.softSurface(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NoorTheme.border(context)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  done ? Icons.verified_outlined : Icons.auto_awesome_outlined,
                  size: 18,
                  color: NoorTheme.accent(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cueText,
                    style: NoorType.meta.copyWith(
                      color: NoorTheme.foreground(context),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Semantics(
                liveRegion: true,
                label: '$title: $count of 7 $unit completed',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count / 7',
                      style: NoorType.tabular(NoorType.hero(
                          size: 32, color: NoorTheme.accent(context))),
                    ),
                    Text(
                      done ? 'Completed' : '$unit Progress',
                      style: NoorType.meta
                          .copyWith(color: NoorTheme.muted(context)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              IconButton(
                tooltip: 'Decrease $unit',
                constraints:
                    const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed:
                    count > 0 ? () => _stepCounter(isTawaf, count - 1) : null,
                icon: const Icon(Icons.remove_circle_outline, size: 28),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: count < 7
                      ? () => _stepCounter(isTawaf, count + 1)
                      : null,
                  icon: Icon(done ? Icons.check_circle : Icons.add),
                  label: Text(done ? 'Complete' : 'Next $unit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
