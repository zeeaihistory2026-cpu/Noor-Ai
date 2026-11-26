import 'package:flutter/material.dart';
import '../../data/islamic_academy_data.dart';
import '../../data/lifestyle_guides_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'qibla_finder_screen.dart';
import 'prayer_settings_screen.dart';

/// Module 15 P2 — Travel Mode & Qasr / Jam' Guide:
/// Interactive Safar distance & stay calculator, Qasr/Jam' Fiqh rules,
/// offline Travel Qibla / destination timing shortcuts, and Sunnah travel Dua.
class TravelWorshipScreen extends StatefulWidget {
  const TravelWorshipScreen({super.key});

  @override
  State<TravelWorshipScreen> createState() => _TravelWorshipScreenState();
}

class _TravelWorshipScreenState extends State<TravelWorshipScreen> {
  final _distanceCtrl = TextEditingController(text: '120');
  final _stayDaysCtrl = TextEditingController(text: '3');
  bool _hanafi = true;

  @override
  void dispose() {
    _distanceCtrl.dispose();
    _stayDaysCtrl.dispose();
    super.dispose();
  }

  double get _km => double.tryParse(_distanceCtrl.text.trim()) ?? 0;
  int get _days => int.tryParse(_stayDaysCtrl.text.trim()) ?? 0;

  double get _minDistanceKm => _hanafi ? 77.2 : 81.0;
  int get _maxStayDays => _hanafi ? 14 : 3;

  bool get _qualifiesDistance => _km >= _minDistanceKm;
  bool get _qualifiesStay => _days <= _maxStayDays;
  bool get _isMusafir => _qualifiesDistance && _qualifiesStay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            const NoorDarkHeader(
              title: 'Travel Worship',
              subtitle: 'Safar calculator, Qasr & Jam’ guidance',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  NoorCard(
                    color: NoorColors.emeraldDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TRAVEL PRAYER STATUS',
                          style: NoorType.eyebrow
                              .copyWith(color: NoorColors.onEmeraldMuted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isMusafir
                              ? 'Shorten 4-Rak’ah Prayers (Qasr)'
                              : 'Pray Full Prayers (Muqim)',
                          style: NoorType.section
                              .copyWith(color: NoorColors.gold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isMusafir
                              ? 'Dhuhr 2 • Asr 2 • Maghrib 3 • Isha 2 • Fajr 2 (after leaving city bounds).'
                              : !_qualifiesDistance
                                  ? 'Trip is under ${_minDistanceKm.toStringAsFixed(1)} km — full 4-rak’ah prayers remain obligatory.'
                                  : 'Planned stay exceeds $_maxStayDays full days — complete all prayers at destination.',
                          style: NoorType.secondary
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NoorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NoorSectionLabel('Journey Parameters'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Hanafi (77.2 km · <15d)'),
                              selected: _hanafi,
                              onSelected: (_) => setState(() => _hanafi = true),
                            ),
                            ChoiceChip(
                              label: const Text('Shafi’i/Maliki/Hanbali (~81 km · <4d)'),
                              selected: !_hanafi,
                              onSelected: (_) =>
                                  setState(() => _hanafi = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _distanceCtrl,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  labelText: 'One-way km',
                                  filled: true,
                                  fillColor: NoorTheme.softSurface(context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: NoorTheme.border(context)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _stayDaysCtrl,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  labelText: 'Stay days',
                                  filled: true,
                                  fillColor: NoorTheme.softSurface(context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(
                                        color: NoorTheme.border(context)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                              minimumSize: const Size(48, 48)),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const QiblaFinderScreen()),
                          ),
                          icon: const Icon(Icons.explore_outlined),
                          label: const Text('Travel Qibla'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                              minimumSize: const Size(48, 48)),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const PrayerSettingsScreen()),
                          ),
                          icon: const Icon(Icons.location_city_outlined),
                          label: const Text('Destination City'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  NoorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const NoorSectionLabel('Prophetic Travel Supplication'),
                        const SizedBox(height: 10),
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
                                LifestyleGuidesData.travelDuaArabic,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: NoorType.arabic(
                                  size: 20,
                                  color: NoorTheme.foreground(context,
                                      light: NoorColors.emeraldDark),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                LifestyleGuidesData.travelDuaTranslit,
                                textAlign: TextAlign.center,
                                style: NoorType.secondary.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: NoorTheme.muted(context),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                LifestyleGuidesData.travelDuaMeaning,
                                textAlign: TextAlign.center,
                                style: NoorType.body,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(LifestyleGuidesData.travelDuaRef,
                            style: NoorType.meta
                                .copyWith(color: NoorTheme.accent(context))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: const Text('Travel Prayer Rules',
                        style: NoorType.section),
                  ),
                  const SizedBox(height: 10),
                  for (final GuideStep s in LifestyleGuidesData.travelSteps) ...[
                    NoorCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              NoorRosetteBadge(s.step, size: 32),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(s.title, style: NoorType.cardTitle)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(s.detail, style: NoorType.body),
                          if (s.reference != null) ...[
                            const SizedBox(height: 6),
                            Text(s.reference!,
                                style: NoorType.meta
                                    .copyWith(color: NoorTheme.accent(context))),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

