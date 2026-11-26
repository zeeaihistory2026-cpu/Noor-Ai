import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/lifestyle_guides_data.dart';
import '../../data/noor_store.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';
import 'fasting_ramadan_screen.dart';

/// Module 16 P2 — Muslim Women's Corner:
/// Private on-device exempt-days pause toggle, Qada fasts link,
/// scholar-cited women's Fiqh rulings, and pregnancy/parenting Duas.
class WomensCornerScreen extends StatefulWidget {
  const WomensCornerScreen({super.key});

  @override
  State<WomensCornerScreen> createState() => _WomensCornerScreenState();
}

class _WomensCornerScreenState extends State<WomensCornerScreen> {
  bool _exemptMode = false;
  int _qadaFasts = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ex = await NoorStore.getCycleExemptMode();
    final qada = await NoorStore.getQadaFasts();
    if (!mounted) return;
    setState(() {
      _exemptMode = ex;
      _qadaFasts = qada;
    });
  }

  Future<void> _toggleExempt(bool val) async {
    HapticFeedback.selectionClick();
    setState(() => _exemptMode = val);
    await NoorStore.setCycleExemptMode(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            const NoorDarkHeader(
              title: 'Women’s Corner',
              subtitle: 'Private on-device worship & Fiqh guidance',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                children: [
                  NoorCard(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: NoorColors.emeraldDark,
                      value: _exemptMode,
                      onChanged: _toggleExempt,
                      title: const Text('Private Exempt-Days Mode',
                          style: NoorType.cardTitle),
                      subtitle: Text(
                        'Stored strictly on this device only. Respectfully pauses Salah expectation notes while keeping Dhikr and Dua reminders.',
                        style: NoorType.meta
                            .copyWith(color: NoorTheme.muted(context)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  NoorCard(
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (_) => const FastingRamadanScreen()))
                        .then((_) => _load()),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: NoorTheme.softSurface(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.nights_stay_outlined,
                              color: NoorTheme.accent(context)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Missed Ramadan Fasts (Qada)',
                                  style: NoorType.cardTitle),
                              const SizedBox(height: 2),
                              Text(
                                '$_qadaFasts day(s) tracked • Tap to adjust in Fasting Tracker',
                                style: NoorType.tabular(NoorType.meta.copyWith(
                                    color: NoorTheme.muted(context))),
                              ),
                            ],
                          ),
                        ),
                        ExcludeSemantics(
                          child: Icon(Icons.chevron_right,
                              color: NoorTheme.muted(context)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Semantics(
                    header: true,
                    child: const Text('Fiqh & Worship Guidance',
                        style: NoorType.section),
                  ),
                  const SizedBox(height: 10),
                  for (final item in LifestyleGuidesData.womensFiqh) ...[
                    NoorCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: NoorType.cardTitle),
                          const SizedBox(height: 6),
                          Text(item.ruling, style: NoorType.body),
                          const SizedBox(height: 6),
                          Text(item.source,
                              style: NoorType.meta
                                  .copyWith(color: NoorTheme.accent(context))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 8),
                  Semantics(
                    header: true,
                    child: const Text('Pregnancy & Parenting Duas',
                        style: NoorType.section),
                  ),
                  const SizedBox(height: 10),
                  for (final dua in LifestyleGuidesData.parentingDuas) ...[
                    NoorCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dua.title, style: NoorType.cardTitle),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: NoorTheme.softSurface(context),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              dua.arabic,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                              style: NoorType.arabic(
                                size: 20,
                                color: NoorTheme.foreground(context,
                                    light: NoorColors.emeraldDark),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(dua.translation, style: NoorType.body),
                          const SizedBox(height: 6),
                          Text(dua.ref,
                              style: NoorType.meta
                                  .copyWith(color: NoorTheme.accent(context))),
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

