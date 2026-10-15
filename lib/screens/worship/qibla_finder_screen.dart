import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../data/app_state.dart';
import '../../data/prayer_service.dart';
import '../../data/sample_data.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

/// Page 10 — Qibla Finder. Cream page (NO dark header in the design),
/// location row + Update Location, gold-ring compass with NW pin,
/// Kaaba crop at centre (real Page 10 art), bearing / direction /
/// distance, direction card with mosque crop, 4 tool tiles,
/// Helpful Tips with lantern crop, Recently Used Locations.
///
/// The needle is wired to PrayerService.fetchQiblaBearing
/// (AlAdhan qibla endpoint, great-circle fallback to Makkah) using
/// the canonical Karachi coordinates from NoorAppState. Until the
/// live bearing arrives, the demo bearing from that same source of
/// truth is shown and labelled as demo — never as measured, and
/// never the design's printed 295° sample. Device compass/heading
/// is not claimed anywhere on this screen.
class QiblaFinderScreen extends StatefulWidget {
  const QiblaFinderScreen({super.key});
  @override
  State<QiblaFinderScreen> createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends State<QiblaFinderScreen> {
  // Canonical Karachi coordinates from NoorAppState (device GPS,
  // when it exists, replaces these in the same fields).
  static const double _lat = 24.8607;
  static const double _lng = 67.0011;
  // Makkah coordinates (from the location row as drawn).
  static const double _makkahLat = 21.4225;
  static const double _makkahLng = 39.8262;

  double _bearing = NoorAppState.qiblaBearing; // canonical demo bearing
  String? _distanceKm;
  bool _live = false;

  @override
  void initState() {
    super.initState();
    _loadBearing();
  }

  Future<void> _loadBearing() async {
    try {
      final b = await PrayerService()
          .fetchQiblaBearing(latitude: _lat, longitude: _lng);
      if (!mounted) return;
      setState(() {
        _bearing = b;
        _distanceKm =
            _haversineKm(_lat, _lng, _makkahLat, _makkahLng).toStringAsFixed(0);
        _live = true;
      });
    } catch (_) {
      /* canonical demo bearing stays, labelled as demo below */
    }
  }

  static const _points = [
    'N',
    'NNE',
    'NE',
    'ENE',
    'E',
    'ESE',
    'SE',
    'SSE',
    'S',
    'SSW',
    'SW',
    'WSW',
    'W',
    'WNW',
    'NW',
    'NNW',
  ];

  String get _cardinal => _points[((_bearing % 360) / 22.5).round() % 16];

  static const _pointWords = {
    'N': 'North',
    'NNE': 'North-northeast',
    'NE': 'Northeast',
    'ENE': 'East-northeast',
    'E': 'East',
    'ESE': 'East-southeast',
    'SE': 'Southeast',
    'SSE': 'South-southeast',
    'S': 'South',
    'SSW': 'South-southwest',
    'SW': 'Southwest',
    'WSW': 'West-southwest',
    'W': 'West',
    'WNW': 'West-northwest',
    'NW': 'Northwest',
    'NNW': 'North-northwest',
  };

  String get _cardinalWord => _pointWords[_cardinal] ?? _cardinal;

  static double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double d) => d * math.pi / 180;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: NoorColors.cream,
        body: SafeArea(
            child: ListView(padding: EdgeInsets.zero, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 14, 0),
              child: Row(children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.of(context).maybePop()),
                const Expanded(
                    child: Text('Qibla Finder',
                        textAlign: TextAlign.center,
                        style: NoorType.section)),
                IconButton(
                    icon: const Icon(Icons.refresh, color: NoorColors.muted),
                    tooltip: 'Recalculate bearing',
                    onPressed: _loadBearing),
              ])),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(children: [
                NoorCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(children: [
                      const Icon(Icons.location_on_outlined,
                          color: NoorColors.emeraldDark),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text(NoorAppState.locationLabel,
                                style: NoorType.secondary),
                            Text(
                                '${NoorAppState.latitude.toStringAsFixed(4)}° N, '
                                '${NoorAppState.longitude.toStringAsFixed(4)}° E · Your location',
                                style: NoorType.meta),
                          ])),
                      FilledButton.icon(
                          onPressed: _loadBearing,
                          icon: const Icon(Icons.my_location, size: 16, color: Colors.white),
                          label: const Text('Update Location',
                              style: TextStyle(color: Colors.white)),
                          style: FilledButton.styleFrom(
                              backgroundColor: NoorColors.emeraldDark,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8))),
                    ])),
                const SizedBox(height: 22),
                // Compass: gold rings, cardinal labels, NW pin, Kaaba centre.
                SizedBox(
                    width: 272,
                    height: 272,
                    child: Stack(alignment: Alignment.center, children: [
                      Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: NoorColors.goldSoft, width: 2.5),
                              color: NoorColors.surfaceWarm)),
                      Container(
                          width: 226,
                          height: 226,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: NoorColors.goldPale))),
                      for (final e in [
                        ('N', Alignment.topCenter),
                        ('NE', const Alignment(0.85, -0.62)),
                        ('E', Alignment.centerRight),
                        ('SE', const Alignment(0.85, 0.62)),
                        ('S', Alignment.bottomCenter),
                        ('SW', const Alignment(-0.85, 0.62)),
                        ('W', Alignment.centerLeft),
                        ('NW', const Alignment(-0.85, -0.62))
                      ])
                        Align(
                            alignment: e.$2,
                            child: Padding(
                                // N sits below the bearing pill so the
                                // full 8-point set stays visible.
                                padding: e.$1 == 'N'
                                    ? const EdgeInsets.only(top: 38)
                                    : const EdgeInsets.all(12),
                                child: Text(e.$1,
                                    style: NoorType.meta.copyWith(fontWeight: e.$1 == _cardinal
                                            ? FontWeight.w900
                                            : FontWeight.w600,
                                        color: e.$1 == _cardinal
                                            ? NoorColors.emeraldDark
                                            : NoorColors.muted)))),
                      Transform.rotate(
                          angle: _bearing * math.pi / 180,
                          child: const Align(
                              alignment: Alignment.topCenter,
                              child: Icon(Icons.navigation,
                                  color: NoorColors.gold, size: 22))),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(NoorAssets.qiblaKaaba,
                              width: 74,
                              cacheWidth: 222,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                  width: 74,
                                  height: 100,
                                  color: NoorColors.emeraldDark,
                                  child: const Icon(Icons.mosque,
                                      color: Colors.white)))),
                      Positioned(
                          top: 0,
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                  color: NoorColors.emeraldDark,
                                  borderRadius: BorderRadius.circular(999)),
                              child: Text(_cardinal,
                                  style: NoorType.meta.copyWith(color: Colors.white)))),
                    ])),
                const SizedBox(height: 14),
                Text('${_bearing.round()}°',
                    style: NoorType.tabular(NoorType.display.copyWith(
                        fontSize: 40, color: NoorColors.emeraldDark))),
                Text('Qibla • $_cardinalWord',
                    style: NoorType.cardTitle),
                const SizedBox(height: 4),
                Text(
                    _live && _distanceKm != null
                        ? 'Approx. $_distanceKm km from Makkah'
                        : 'Approx. ${NoorAppState.qiblaDistanceLabel}',
                    style: NoorType.meta.copyWith(color: NoorColors.muted)),
                const SizedBox(height: 4),
                Text(
                  _live
                      ? 'Live bearing for ${NoorAppState.locationLabel}'
                      : 'Demo bearing for ${NoorAppState.locationLabel}',
                  textAlign: TextAlign.center,
                  style: NoorType.meta.copyWith(color: NoorColors.muted),
                ),
                const SizedBox(height: 18),
                NoorCard(
                    child: Row(children: [
                  Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                          color: NoorColors.emeraldDark,
                          shape: BoxShape.circle),
                      child: const Icon(Icons.navigation,
                          color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            'Qibla is ${_bearing.round()}° — to your $_cardinalWord',
                            style: NoorType.body),
                        Text('Stand straight and face the direction',
                            style: NoorType.meta.copyWith(color: NoorColors.muted)),
                      ])),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(NoorAssets.qiblaMosque,
                          width: 62,
                          cacheWidth: 186,
                          height: 52,
                          // Whole minarets + Kaaba in the box
                          // (Phase 11b): cover cropped the tops off
                          // this tall asset; its white ground matches
                          // the white card, so contain shows no seam.
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const SizedBox(width: 62, height: 52))),
                ])),
                const SizedBox(height: 14),
                Row(children: [
                  _tool(Icons.explore_outlined, 'Compass', onTap: _loadBearing),
                  _tool(Icons.center_focus_weak, 'AR View', soon: true),
                  _tool(Icons.wb_sunny_outlined, 'Sun Position', soon: true),
                  _tool(Icons.map_outlined, 'Map View', soon: true),
                ]),
                const SizedBox(height: 14),
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: NoorColors.emeraldSoft,
                        borderRadius: BorderRadius.circular(NoorRadius.card)),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Helpful Tips',
                                    style: NoorType.body),
                                SizedBox(height: 10),
                                _Tip(
                                    'Ensure your device is placed on a flat surface.'),
                                _Tip('Avoid magnetic cases or nearby metals.'),
                                _Tip(
                                    'For best accuracy, enable location services.'),
                              ])),
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(NoorAssets.lantern,
                                  width: 56,
                                  cacheWidth: 168,
                                  height: 74,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(width: 56, height: 74))),
                        ])),
                const SizedBox(height: 20),
                Row(children: [
                  const Expanded(child: NoorSectionLabel('Recently Used Locations')),
                  Text('View All',
                      style: NoorType.meta.copyWith(color: NoorColors.emerald))
                ]),
                const SizedBox(height: 10),
                for (final l in SampleData.qiblaSaved) ...[
                  NoorCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: Row(children: [
                        const Icon(Icons.location_on,
                            color: NoorColors.emeraldDark, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(l.$1,
                                  style: NoorType.secondary),
                              Text(l.$2,
                                  style: NoorType.meta.copyWith(color: NoorColors.muted))
                            ])),
                        Text(l.$3,
                            style: NoorType.meta),
                        const Icon(Icons.chevron_right,
                            color: NoorColors.muted, size: 18),
                      ])),
                  const SizedBox(height: 10),
                ],
              ])),
        ])),
      );
  Widget _tool(IconData i, String t,
          {VoidCallback? onTap, bool soon = false}) =>
      Expanded(
          child: Semantics(
              button: true,
              label: soon ? '$t, coming soon' : t,
              child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                      onTap: onTap ??
                          (soon
                              ? () => ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      content: Text('$t is coming soon')))
                              : null),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                          constraints: const BoxConstraints(minHeight: 44),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: NoorColors.hairline)),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Icon(i, color: NoorColors.emeraldDark, size: 22),
                            const SizedBox(height: 7),
                            Text(t,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: NoorType.meta),
                            if (soon)
                              Text('Coming soon',
                                  textAlign: TextAlign.center,
                                  style: NoorType.meta.copyWith(
                                      color: NoorColors.muted, fontSize: 10)),
                          ]))))));
}

class _Tip extends StatelessWidget {
  const _Tip(this.t);
  final String t;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.check_circle, size: 15, color: NoorColors.emerald),
        const SizedBox(width: 7),
        Expanded(
            child: Text(t, style: NoorType.meta.copyWith(height: 1.4)))
      ]));
}
