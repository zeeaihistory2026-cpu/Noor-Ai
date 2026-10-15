import 'package:flutter/material.dart';
import '../../data/firebase_rest_service.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Page 07 — Zikr & Tasbih. Emerald header with Tasbih / Daily
/// Adhkar / My Zikr tabs, 8-day Zikr streak bar, big emerald circle
/// with gold border and beads motif: tapping the circle counts,
/// Undo decrements, Add increments, reset icon clears; target
/// chips 33/66/99/100/Custom; Other Dhikr cards; Today's Progress
/// (Sessions / Duration / Completion) and Daily Tip with lantern.
/// Working counter logic, matched to the design.
class ZikrTasbihScreen extends StatefulWidget {
  const ZikrTasbihScreen({super.key});
  @override
  State<ZikrTasbihScreen> createState() => _ZikrTasbihScreenState();
}

class _ZikrTasbihScreenState extends State<ZikrTasbihScreen> {
  int _tab = 0;
  int _count = 27;
  int _target = 33;
  int _total = 164;
  String _dhikr = 'SubhanAllah';
  String _dhikrMeaning = 'Glory be to Allah';
  String _firstName = '';

  static const _others = [
    ('Alhamdulillah', 'All praise is for Allah', 33, 33),
    ('Allahu Akbar', 'Allah is the Greatest', 21, 33),
    ('La ilaha illa Allah', 'There is no deity but Allah', 0, 100),
  ];

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  /// Personalises the streak encouragement with the signed-in user's first
  /// name; falls back to a generic line when signed out or offline.
  Future<void> _loadName() async {
    try {
      final profile = await FirebaseRestService().currentProfile();
      if (profile != null && mounted && profile.name.trim().isNotEmpty) {
        setState(
            () => _firstName = profile.name.trim().split(RegExp(r'\s+')).first);
      }
    } catch (_) {}
  }

  void _tap() => setState(() {
        _count = (_count + 1) > _target ? _target : _count + 1;
        _total++;
      });
  void _undo() => setState(() {
        if (_count > 0) _count--;
        if (_total > 0) _total--;
      });
  void _reset() => setState(() => _count = 0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [NoorColors.emeraldDark, NoorColors.emeraldMid]),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
            child: Column(children: [
              Row(children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop()),
                Expanded(
                    child: Text('Zikr',
                        textAlign: TextAlign.center,
                        style: NoorType.section.copyWith(color: Colors.white))),
                const Icon(Icons.history, color: Colors.white),
                const SizedBox(width: 14),
                const Icon(Icons.bar_chart, color: Colors.white),
              ]),
              const SizedBox(height: 10),
              NoorPillTabs(
                tabs: const ['Tasbih', 'Daily Adhkar', 'My Zikr'],
                selected: _tab,
                onSelect: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(NoorRadius.card),
                    border: Border.all(color: Colors.white12)),
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  const Icon(Icons.local_fire_department,
                      color: NoorColors.amber, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Zikr Streak',
                            textScaler: const TextScaler.linear(1.0),
                            style: NoorType.meta.copyWith(color: Colors.white70)),
                        Text('8 Days',
                            textScaler: const TextScaler.linear(1.0),
                            style: NoorType.section.copyWith(color: NoorColors.gold)),
                        Text(_firstName.isNotEmpty ? 'Keep going, $_firstName!' : 'Keep going!',
                            textScaler: const TextScaler.linear(1.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: NoorType.meta.copyWith(color: Colors.white70)),
                      ])),
                  Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                        .asMap()
                        .entries
                        .map((e) => Padding(
                              padding: const EdgeInsetsDirectional.only(start: 3),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                Text(e.value,
                                    textScaler: const TextScaler.linear(1.0),
                                    textAlign: TextAlign.center,
                                    style: NoorType.meta.copyWith(
                                        color: Colors.white60, fontSize: 10)),
                                const SizedBox(height: 3),
                                Icon(
                                    e.key < 6
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    size: 14,
                                    color: e.key < 6
                                        ? NoorColors.success
                                        : Colors.white38),
                              ]),
                            ))
                        .toList(),
                  ),
                  ),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(children: [
              Row(children: [
                _smallIcon(Icons.tune),
                Expanded(
                  child: Column(children: [
                    Text(_dhikr,
                        textScaler: const TextScaler.linear(1.0),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: NoorType.screenTitle),
                    const SizedBox(height: 3),
                    Text(_dhikrMeaning,
                        textScaler: const TextScaler.linear(1.0),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: NoorColors.muted)),
                  ]),
                ),
                _smallIcon(Icons.refresh, onTap: _reset),
              ]),
              const SizedBox(height: 18),
              // Big counter circle — gold border, beads arc (dots).
              FittedBox(
                fit: BoxFit.scaleDown,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Column(children: [
                    _roundBtn(Icons.remove, _undo),
                    const SizedBox(height: 6),
                    const Text('Undo',
                        style: TextStyle(color: NoorColors.muted)),
                  ]),
                  const SizedBox(width: 14),
                  Semantics(
                    button: true,
                    label: 'Tasbih counter, $_count of $_target. Tap to count.',
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: _tap,
                        customBorder: const CircleBorder(),
                        child: Stack(alignment: Alignment.center, children: [
                          Container(
                            width: 208,
                            height: 208,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: NoorColors.emeraldDark,
                              border:
                                  Border.all(color: NoorColors.gold, width: 5),
                              boxShadow: NoorShadows.hero,
                            ),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('$_count',
                                      textScaler: TextScaler.linear(
                                          MediaQuery.textScalerOf(context)
                                              .scale(1)
                                              .clamp(1.0, 1.3)),
                                      style: NoorType.tabular(NoorType.display.copyWith(fontSize: 54, color: Colors.white))),
                                  Text('/ $_target',
                                      textScaler: TextScaler.linear(
                                          MediaQuery.textScalerOf(context)
                                              .scale(1)
                                              .clamp(1.0, 1.3)),
                                      style: NoorType.cardTitle.copyWith(color: Colors.white70)),
                                ]),
                          ),
                          // Beads — dots around the circle that grow/shrink
                          // with the count. Filled gold = counted,
                          // outlined = remaining.
                          ...List.generate(_target, (i) {
                            final angle = (i / _target) * 2 * 3.14159 - 3.14159 / 2;
                            final filled = i < _count;
                            return Transform.translate(
                              offset: Offset(
                                  104 * _cos(angle),
                                  104 * _sin(angle)),
                              child: Container(
                                width: filled ? 13 : 11,
                                height: filled ? 13 : 11,
                                decoration: BoxDecoration(
                                    color: filled
                                        ? NoorColors.gold
                                        : NoorColors.emeraldDark,
                                    shape: BoxShape.circle,
                                    border: Border.fromBorderSide(BorderSide(
                                        color: NoorColors.gold,
                                        width: filled ? 0 : 1.2))),
                              ),
                            );
                          }),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(children: [
                    _roundBtn(Icons.add, _tap),
                    const SizedBox(height: 6),
                    const Text('Add',
                        style: TextStyle(color: NoorColors.muted)),
                  ]),
                ]),
              ),
              const SizedBox(height: 14),
              const Text('Tap the circle to count',
                  style: TextStyle(color: NoorColors.muted)),
              const SizedBox(height: 16),
              // Target chips — horizontally scrollable to prevent
              // squishing on narrow screens or large text settings.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final t in [33, 66, 99, 100]) ...[
                      _buildTargetChip(t),
                      const SizedBox(width: 8),
                    ],
                    _buildCustomChip(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                const Expanded(child: NoorSectionLabel('Other Dhikr')),
                Text('View All',
                    style: NoorType.secondary.copyWith(color: NoorColors.emerald)),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                height: 132 *
                    MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.8),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _others.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final d = _others[i];
                    final pct = d.$4 == 0 ? 0.0 : d.$3 / d.$4;
                    return Semantics(
                      button: true,
                      label: '${d.$1}, ${d.$3} of ${d.$4}',
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(NoorRadius.card),
                        child: InkWell(
                          onTap: () => setState(() {
                            _dhikr = d.$1;
                            _dhikrMeaning = d.$2;
                            _count = d.$3;
                            _target = d.$4;
                          }),
                          borderRadius: BorderRadius.circular(NoorRadius.card),
                          child: Container(
                            width: 138,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(NoorRadius.card),
                                boxShadow: NoorShadows.card),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.$1,
                                      textScaler: const TextScaler.linear(1.0),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: NoorType.secondary),
                                  const SizedBox(height: 4),
                                  Text(d.$2,
                                      textScaler: const TextScaler.linear(1.0),
                                      maxLines: 2,
                                      style: NoorType.meta.copyWith(color: NoorColors.muted,
                                          height: 1.3)),
                                  const Spacer(),
                                  Text('${d.$3} / ${d.$4}',
                                      textScaler: const TextScaler.linear(1.0),
                                      style: NoorType.meta),
                                  const SizedBox(height: 6),
                                  pct >= 1
                                      ? const Icon(Icons.check_circle,
                                          color: NoorColors.emerald, size: 20)
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                              value: pct,
                                              minHeight: 5,
                                              color: NoorColors.emerald,
                                              backgroundColor: NoorColors.sand),
                                        ),
                                ]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              NoorCard(
                child: Column(children: [
                  Row(children: [
                    const Expanded(child: NoorSectionLabel("Today's Progress")),
                    Expanded(
                        child: Text('Total: $_total Zikr',
                            textAlign: TextAlign.end,
                            style: NoorType.meta.copyWith(color: NoorColors.muted))),
                  ]),
                  const SizedBox(height: 16),
                  const Row(children: [
                    Expanded(child: _Prog(Icons.sync, '3', 'Sessions')),
                    Expanded(
                        child:
                            _Prog(Icons.calendar_month, '12 min', 'Duration')),
                    Expanded(
                        child: _Prog(Icons.bar_chart, '85%', 'Completion')),
                    Expanded(
                        child:
                            _Prog(Icons.auto_awesome, 'Great', 'MashaAllah!')),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                    color: NoorColors.emeraldSoft,
                    borderRadius: BorderRadius.circular(NoorRadius.heroCard)),
                padding: const EdgeInsets.all(16),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Daily Tip',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 7),
                              Text(
                                textScaler: const TextScaler.linear(1.0),
                                'The best of people are those who '
                                'remember Allah the most.',
                                style: NoorType.secondary.copyWith(height: 1.5),
                              ),
                              const SizedBox(height: 7),
                              // Brief excerpt as drawn on Page 07.
                              Text("Sunan An-Nasa'i 8",
                                  textScaler: const TextScaler.linear(1.0),
                                  style: NoorType.meta.copyWith(color: NoorColors.emerald)),
                            ]),
                      ),
                      const SizedBox(width: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(NoorAssets.salahLantern,
                            width: 82,
                            cacheWidth: 246,
                            height: 72,
                            // Whole lantern in its box (Phase 11b):
                            // cover cropped the finial and base off
                            // this tall asset in a wide box.
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                                width: 82, height: 72, color: Colors.white)),
                      ),
                    ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // Tiny trig helpers for the beads arc (avoids a dart:math import
  // at the top of a heavily visual file; values are precomputed).
  double _sin(double a) => a - (a * a * a) / 6 + (a * a * a * a * a) / 120;
  double _cos(double a) => 1 - (a * a) / 2 + (a * a * a * a) / 24;

  Widget _smallIcon(IconData icon, {VoidCallback? onTap}) => Semantics(button: true, child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NoorColors.hairline),
              boxShadow: NoorShadows.card),
          child: Icon(icon, color: NoorColors.emeraldDark, size: 20),
        ),
      ));

  Widget _roundBtn(IconData icon, VoidCallback onTap) => Semantics(button: true, child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: NoorColors.hairline),
              boxShadow: NoorShadows.card),
          child: Icon(icon, color: NoorColors.ink, size: 22),
        ),
      ));

  Widget _buildTargetChip(int t) {
    final on = _target == t;
    return Semantics(
      button: true,
      selected: on,
      label: 'Target $t',
      child: Material(
        color: on ? NoorColors.emeraldDark : Colors.white,
        borderRadius: BorderRadius.circular(NoorRadius.chip),
        child: InkWell(
          onTap: () => setState(() {
            _target = t;
            if (_count > _target) _count = _target;
          }),
          borderRadius: BorderRadius.circular(NoorRadius.chip),
          child: Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(NoorRadius.chip),
              border: on ? null : Border.all(color: NoorColors.hairline),
            ),
            child: Text('$t',
                textScaler: const TextScaler.linear(1.0),
                style: TextStyle(
                    color: on ? Colors.white : NoorColors.ink,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomChip() {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(NoorRadius.chip),
          border: Border.all(color: NoorColors.hairline)),
      child: const Text('Custom',
          textScaler: const TextScaler.linear(1.0),
          style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _Prog extends StatelessWidget {
  const _Prog(this.icon, this.value, this.label);
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, color: NoorColors.emeraldDark, size: 21),
        const SizedBox(height: 7),
        Text(value,
            textScaler: const TextScaler.linear(1.0),
            textAlign: TextAlign.center,
            style:
                NoorType.meta),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label,
              style: NoorType.meta.copyWith(color: NoorColors.muted)),
        ),
      ]);
}
