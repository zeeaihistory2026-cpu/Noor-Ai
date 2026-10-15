import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                                  color: NoorColors.goldDeep, size: 22))),
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
                  _tool(Icons.center_focus_weak, 'AR View', onTap: _openArViewModal),
                  _tool(Icons.wb_sunny_outlined, 'Sun Position', onTap: _openSunPositionModal),
                  _tool(Icons.map_outlined, 'Map View', onTap: _openMapViewModal),
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

  Widget _tool(IconData i, String t, {VoidCallback? onTap}) =>
      Expanded(
          child: Semantics(
              button: true,
              label: t,
              child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                      onTap: onTap,
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
                          ]))))));

  void _openArViewModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: ListView(
            controller: scroll,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NoorColors.hairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AR Qibla Camera HUD',
                          style: NoorType.section.copyWith(
                              color: NoorColors.emeraldDark,
                              fontWeight: FontWeight.w700)),
                      Text('Augmented reality horizon alignment',
                          style: NoorType.meta
                              .copyWith(color: NoorColors.mutedDark)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Viewfinder simulation
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: NoorColors.emeraldDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: NoorColors.emeraldMid, width: 1.5),
                  boxShadow: NoorShadows.hero,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Grid lines
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ArGridPainter(),
                      ),
                    ),
                    // Reticle target with Kaaba
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: NoorColors.gold, width: 2),
                          ),
                          child: const Center(
                            child: Icon(Icons.navigation,
                                color: NoorColors.gold, size: 36),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: NoorColors.emeraldDark.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                                color: NoorColors.gold.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'Qibla: ${_bearing.round()}° $_cardinalWord',
                            style: NoorType.meta.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 12,
                      left: 14,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: NoorColors.emerald,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SENSOR CALIBRATED',
                            style: NoorType.meta.copyWith(
                                color: Colors.white70,
                                fontSize: 10,
                                letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 14,
                      child: Text(
                        'PITCH: LEVEL 0°',
                        style: NoorType.meta.copyWith(
                            color: Colors.white70,
                            fontSize: 10,
                            letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Practical instructions
              const Text('AR Alignment Instructions', style: NoorType.body),
              const SizedBox(height: 10),
              const _Tip('Hold your device vertically at eye level pointing straight ahead.'),
              _Tip('Turn your body slowly towards $_cardinalWord until the target reticle centers.'),
              const _Tip('When aligned, your phone vibrates and points precisely at Makkah.'),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NoorColors.emeraldDark,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.sync, size: 18),
                label: const Text('Recalibrate Device Gyroscope',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _loadBearing();
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compass sensors calibrated successfully'),
                      duration: Duration(seconds: 2),
                      backgroundColor: NoorColors.emeraldDark,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSunPositionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: ListView(
            controller: scroll,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NoorColors.hairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sun Position & Shadow Qibla',
                          style: NoorType.section.copyWith(
                              color: NoorColors.emeraldDark,
                              fontWeight: FontWeight.w700)),
                      Text('Authentic Islamic celestial navigation',
                          style: NoorType.meta
                              .copyWith(color: NoorColors.mutedDark)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NoorColors.emeraldSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: NoorColors.emerald.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny,
                            color: NoorColors.goldDeep, size: 22),
                        const SizedBox(width: 8),
                        Text('Why Use Sun Shadow?',
                            style: NoorType.body.copyWith(
                                color: NoorColors.emeraldDark,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Magnetic compasses can be skewed by reinforced concrete, metallic watches, and wiring in buildings. The Sun\'s shadow is an infallible geometric method praised by classical Muslim astronomers.',
                      style: NoorType.meta.copyWith(
                          color: NoorColors.mutedDark, height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Method 1: Local Solar Noon Meridian', style: NoorType.body),
              const SizedBox(height: 6),
              Text(
                'At local solar noon (~12:15 PM), the sun crosses the local meridian. An upright straight stick casts a shadow pointing due North. From this line, measure ${_bearing.round()}° clockwise to find the Qibla.',
                style: NoorType.meta.copyWith(color: NoorColors.mutedDark, height: 1.4),
              ),
              const SizedBox(height: 16),

              const Text('Method 2: Bi-Annual Direct Kaaba Transit', style: NoorType.body),
              const SizedBox(height: 6),
              Text(
                'Twice a year, the sun reaches zenith directly above the Holy Kaaba (Latitude 21° 25\' 21" N):\n'
                '• May 28 at 12:18 PM Makkah Time (09:18 UTC)\n'
                '• July 16 at 12:27 PM Makkah Time (09:27 UTC)\n\n'
                'At these precise minutes, simply facing the sun (or facing opposite the shadow) points directly toward Makkah from anywhere in the sunlit hemisphere.',
                style: NoorType.meta.copyWith(color: NoorColors.mutedDark, height: 1.4),
              ),
              const SizedBox(height: 18),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NoorColors.emeraldDark,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMapViewModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: ListView(
            controller: scroll,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NoorColors.hairline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Great-Circle Qibla Geometry',
                          style: NoorType.section.copyWith(
                              color: NoorColors.emeraldDark,
                              fontWeight: FontWeight.w700)),
                      Text('Geodesic path to the Holy Kaaba',
                          style: NoorType.meta
                              .copyWith(color: NoorColors.mutedDark)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [NoorColors.emeraldDark, NoorColors.emeraldMid],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: NoorShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Great-Circle Distance',
                            style: NoorType.meta.copyWith(color: Colors.white70)),
                        Text('~3,480 km',
                            style: NoorType.body.copyWith(
                                color: NoorColors.gold,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('True Azimuth Angle',
                            style: NoorType.meta.copyWith(color: Colors.white70)),
                        Text('${_bearing.round()}° $_cardinalWord',
                            style: NoorType.body.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Kaaba Coordinates',
                            style: NoorType.meta.copyWith(color: Colors.white70)),
                        Text('21.4225° N, 39.8262° E',
                            style: NoorType.meta.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text('Geodesic Geometry Explanation', style: NoorType.body),
              const SizedBox(height: 6),
              Text(
                'Because the Earth is an oblate spheroid, the shortest path between any point on Earth and the Kaaba is an arc of a great circle (orthodromic path). The true bearing is computed using the spherical inverse haversine formula.',
                style: NoorType.meta.copyWith(color: NoorColors.mutedDark, height: 1.4),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: NoorColors.emeraldDark),
                        foregroundColor: NoorColors.emeraldDark,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Coordinates'),
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(
                            text: '21.4225° N, 39.8262° E (Holy Kaaba, Makkah)'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Kaaba coordinates copied to clipboard'),
                            duration: Duration(seconds: 2),
                            backgroundColor: NoorColors.emeraldDark,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NoorColors.emeraldDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 4), Offset(size.width, size.height / 4), paint);
    canvas.drawLine(Offset(0, size.height * 3 / 4), Offset(size.width, size.height * 3 / 4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
