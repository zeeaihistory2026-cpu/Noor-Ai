import 'package:flutter/material.dart';
import '../../data/islamic_academy_data.dart';
import '../../data/location_service.dart';
import '../../data/noor_controller.dart';
import '../../data/noor_store.dart';
import '../../data/prayer_service.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Module 02 P1/P2 — Wudu, Ghusl, Step-by-Step Salah Guide, Qada Tracker,
/// and Tahajjud Last-Third Night Calculator.
class SalahGuideScreen extends StatefulWidget {
  const SalahGuideScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<SalahGuideScreen> createState() => _SalahGuideScreenState();
}

class _SalahGuideScreenState extends State<SalahGuideScreen> {
  late int _tab;
  Map<String, int> _qada = const {};

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab.clamp(0, 3);
    _loadQada();
  }

  Future<void> _loadQada() async {
    final qada = await NoorStore.getQadaPrayers();
    if (mounted) setState(() => _qada = qada);
  }

  Future<void> _updateQada(String prayer, int delta) async {
    final current = _qada[prayer] ?? 0;
    final next = (current + delta).clamp(0, 99999);
    setState(() {
      _qada = Map<String, int>.from(_qada)..[prayer] = next;
    });
    await NoorStore.setQadaPrayerCount(prayer, next);
  }

  @override
  Widget build(BuildContext context) {
    final controller = NoorScope.of(context);
    final day = controller?.activeDay ??
        PrayerService.calculateOffline(
          location: LocationModel.defaultLocation,
          date: PrayerService.nowInLocation(LocationModel.defaultLocation),
        );

    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            NoorDarkHeader(
              title: 'Salah & Purification',
              subtitle: 'Wudu, Ghusl, Prayer steps & Tahajjud',
              child: NoorPillTabs(
                tabs: const ['Salah', 'Wudu', 'Ghusl', 'Qada & Night'],
                selected: _tab,
                onSelect: (i) => setState(() => _tab = i),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  _buildStepsList(
                    title: 'Step-by-Step Salah Guide',
                    subtitle:
                        'Core postures, supplications, and daily Raka’at summary.',
                    steps: IslamicAcademyData.salahSteps,
                    footer: _buildRakaatSection(context),
                  ),
                  _buildStepsList(
                    title: 'Step-by-Step Wudu (Ablution)',
                    subtitle:
                        'Purification required before Salah. Marked items are obligatory (Fard).',
                    steps: IslamicAcademyData.wuduSteps,
                  ),
                  _buildStepsList(
                    title: 'Step-by-Step Ghusl (Full Purification)',
                    subtitle:
                        'Complete ritual bath in the prophetic sequence.',
                    steps: IslamicAcademyData.ghuslSteps,
                  ),
                  _buildQadaAndTahajjudTab(context, day),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsList({
    required String title,
    required String subtitle,
    required List<GuideStep> steps,
    Widget? footer,
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Semantics(
          header: true,
          child: Text(title, style: NoorType.section),
        ),
        const SizedBox(height: 6),
        Text(subtitle,
            style: NoorType.secondary.copyWith(color: NoorTheme.muted(context))),
        const SizedBox(height: 16),
        for (final step in steps) ...[
          NoorCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NoorRosetteBadge(step.step, size: 34),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.title, style: NoorType.cardTitle),
                          if (step.isObligatory) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: NoorTheme.softSurface(context),
                                borderRadius:
                                    BorderRadius.circular(NoorRadius.chip),
                                border: Border.all(
                                    color: NoorTheme.softBorder(context)),
                              ),
                              child: Text('Obligatory (Fard)',
                                  style: NoorType.compactMeta.copyWith(
                                      color: NoorTheme.accent(context))),
                            ),
                          ],
                        ],
                      ),
                    ),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          step.arabic!,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: NoorType.arabic(
                            size: 21,
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
                                color: NoorTheme.muted(context)),
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
        if (footer != null) ...[const SizedBox(height: 8), footer],
      ],
    );
  }

  Widget _buildRakaatSection(BuildContext context) {
    return NoorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NoorSectionLabel('Daily Raka’at Overview'),
          const SizedBox(height: 10),
          for (var i = 0; i < IslamicAcademyData.rakaatTable.length; i++) ...[
            if (i > 0) Divider(height: 18, color: NoorTheme.softBorder(context)),
            Builder(builder: (context) {
              final r = IslamicAcademyData.rakaatTable[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(r.prayer, style: NoorType.cardTitle),
                      Text(
                        '${r.fard} Fard',
                        style: NoorType.tabular(NoorType.meta
                            .copyWith(color: NoorTheme.accent(context))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(r.note,
                      style: NoorType.meta
                          .copyWith(color: NoorTheme.muted(context))),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildQadaAndTahajjudTab(BuildContext context, PrayerDay day) {
    final maghrib = day.timings['Maghrib'];
    final fajr = day.timings['Fajr'];
    DateTime? tahajjudStart;
    DateTime? midnight;
    if (maghrib != null && fajr != null) {
      final nextFajr = fajr.isAfter(maghrib)
          ? fajr
          : fajr.add(const Duration(days: 1));
      final night = nextFajr.difference(maghrib);
      midnight = maghrib.add(Duration(seconds: night.inSeconds ~/ 2));
      tahajjudStart =
          nextFajr.subtract(Duration(seconds: night.inSeconds ~/ 3));
    }

    final totalQada = _qada.values.fold<int>(0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        NoorCard(
          color: NoorColors.emeraldDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TAHAJJUD CALCULATOR',
                  style: NoorType.eyebrow
                      .copyWith(color: NoorColors.onEmeraldMuted)),
              const SizedBox(height: 8),
              Text(
                tahajjudStart == null
                    ? 'Unavailable'
                    : '${PrayerService.formatTime(tahajjudStart)} – ${PrayerService.formatTime(fajr!)}',
                style: NoorType.tabular(
                    NoorType.screenTitle.copyWith(color: NoorColors.gold)),
              ),
              const SizedBox(height: 6),
              Text(
                tahajjudStart == null
                    ? 'Select a location to calculate night thirds.'
                    : 'Best time is the last third of the night (calculated between Maghrib ${PrayerService.formatTime(maghrib!)} and Fajr ${PrayerService.formatTime(fajr!)}).',
                style: NoorType.secondary
                    .copyWith(color: NoorColors.onEmeraldMuted),
              ),
              if (midnight != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Islamic midnight: ${PrayerService.formatTime(midnight)}',
                  style: NoorType.tabular(
                      NoorType.meta.copyWith(color: Colors.white)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text('Qada (Missed Prayer) Tracker',
                  style: NoorType.section),
            ),
            Text('$totalQada total',
                style: NoorType.tabular(
                    NoorType.meta.copyWith(color: NoorTheme.accent(context)))),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Track missed obligatory prayers privately on this device. Tap − after making up a prayer.',
          style: NoorType.secondary.copyWith(color: NoorTheme.muted(context)),
        ),
        const SizedBox(height: 14),
        NoorCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0;
                  i < const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Witr'].length;
                  i++) ...[
                if (i > 0)
                  Divider(height: 1, color: NoorTheme.softBorder(context)),
                Builder(builder: (context) {
                  final prayer = const [
                    'Fajr',
                    'Dhuhr',
                    'Asr',
                    'Maghrib',
                    'Isha',
                    'Witr'
                  ][i];
                  final count = _qada[prayer] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            prayer == 'Dhuhr' ? 'Zuhr / Dhuhr' : prayer,
                            style: NoorType.cardTitle,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Decrease $prayer Qada',
                          onPressed:
                              count > 0 ? () => _updateQada(prayer, -1) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        SizedBox(
                          width: 44,
                          child: Text(
                            '$count',
                            textAlign: TextAlign.center,
                            style: NoorType.tabular(NoorType.cardTitle),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Increase $prayer Qada',
                          onPressed: () => _updateQada(prayer, 1),
                          icon: Icon(Icons.add_circle_outline,
                              color: NoorTheme.accent(context)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

