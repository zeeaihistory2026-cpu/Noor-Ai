import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/islamic_academy_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Module 13 P1/P2 — Hajj & Umrah Guide:
/// Umrah steps, Hajj days overview, Ihram rules & prohibitions,
/// pilgrimage Duas, and interactive Tawaf (7) & Sa'i (7) counters.
class HajjUmrahScreen extends StatefulWidget {
  const HajjUmrahScreen({super.key});

  @override
  State<HajjUmrahScreen> createState() => _HajjUmrahScreenState();
}

class _HajjUmrahScreenState extends State<HajjUmrahScreen> {
  int _tab = 0;
  int _tawaf = 0;
  int _sai = 0;

  void _stepCounter(bool isTawaf, int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      if (isTawaf) {
        _tawaf = (_tawaf + delta).clamp(0, 7);
      } else {
        _sai = (_sai + delta).clamp(0, 7);
      }
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
              title: 'Hajj & Umrah',
              subtitle: 'Step-by-step pilgrimage guide & counters',
              child: NoorPillTabs(
                tabs: const ['Umrah', 'Hajj', 'Counters & Ihram'],
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

  Widget _buildCountersAndIhram() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        _counterCard(
          title: 'Tawaf Counter',
          subtitle: '7 counter-clockwise circuits around the Kaaba',
          count: _tawaf,
          unit: 'Circuit',
          onMinus: () => _stepCounter(true, -1),
          onPlus: () => _stepCounter(true, 1),
          onReset: () => setState(() => _tawaf = 0),
        ),
        const SizedBox(height: 14),
        _counterCard(
          title: 'Sa’i Counter',
          subtitle: '7 laps between Safa and Marwah (ending at Marwah)',
          count: _sai,
          unit: 'Lap',
          onMinus: () => _stepCounter(false, -1),
          onPlus: () => _stepCounter(false, 1),
          onReset: () => setState(() => _sai = 0),
        ),
        const SizedBox(height: 18),
        NoorCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NoorSectionLabel('Ihram Rules & Prohibitions'),
              const SizedBox(height: 10),
              for (var i = 0;
                  i < IslamicAcademyData.ihramProhibitions.length;
                  i++) ...[
                if (i > 0) const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 18, color: NoorTheme.accent(context)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(IslamicAcademyData.ihramProhibitions[i],
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
    required String title,
    required String subtitle,
    required int count,
    required String unit,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required VoidCallback onReset,
  }) {
    return NoorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              TextButton(onPressed: onReset, child: const Text('Reset')),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  label: '$title: $count of 7 $unit completed',
                  child: Text(
                    '$count / 7',
                    style: NoorType.tabular(NoorType.hero(
                        size: 32, color: NoorTheme.accent(context))),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Decrease $unit',
                onPressed: count > 0 ? onMinus : null,
                icon: const Icon(Icons.remove_circle_outline, size: 28),
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                onPressed: count < 7 ? onPlus : null,
                icon: const Icon(Icons.add),
                label: Text(count >= 7 ? 'Complete' : 'Next $unit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

