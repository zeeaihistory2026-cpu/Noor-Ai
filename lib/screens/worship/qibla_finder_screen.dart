import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/compass_service.dart';
import '../../data/location_service.dart';
import '../../data/noor_controller.dart';
import '../../theme/noor_theme.dart';
import '../../widgets/noor_components.dart';

class QiblaFinderScreen extends StatefulWidget {
  const QiblaFinderScreen({super.key});
  @override
  State<QiblaFinderScreen> createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends State<QiblaFinderScreen> {
  LocationModel _location = LocationModel.defaultLocation;
  CompassReading? _reading;
  StreamSubscription<CompassReading>? _subscription;
  String _status = 'Waiting for compass sensor';
  int _request = 0;

  double get _bearing {
    final lat = _location.latitude * math.pi / 180;
    const makkah = 21.4225 * math.pi / 180;
    final delta = (39.8262 - _location.longitude) * math.pi / 180;
    return (math.atan2(
                    math.sin(delta),
                    math.cos(lat) * math.tan(makkah) -
                        math.sin(lat) * math.cos(delta)) *
                180 /
                math.pi +
            360) %
        360;
  }

  bool get _aligned => _reading?.alignedWith(_bearing) ?? false;

  @override
  void initState() {
    super.initState();
    LocationService.getCachedLocation().then((location) {
      if (mounted) _useLocation(location);
    });
  }

  Future<void> _useLocation(LocationModel location) async {
    final request = ++_request;
    await _subscription?.cancel();
    if (!mounted || request != _request) return;
    setState(() {
      _location = location;
      _reading = null;
      _status = 'Waiting for compass sensor';
    });
    _subscription =
        CompassService.readings(location.latitude, location.longitude).listen(
            (reading) {
      if (!mounted || request != _request) return;
      final wasAligned = _aligned;
      setState(() {
        _reading = reading;
        _status = reading.accuracy >= 2
            ? 'Sensor active • True north'
            : 'Low accuracy • Move phone in a figure eight';
      });
      if (_aligned && !wasAligned) HapticFeedback.selectionClick();
    }, onError: (Object error) {
      if (!mounted || request != _request) return;
      setState(() {
        _reading = null;
        _status = 'Compass unavailable • Bearing shown from true north';
      });
    });
  }

  Future<void> _pickLocation() async {
    final location = await LocationService.showLocationPicker(context: context);
    if (location == null || !mounted) return;
    NoorScope.read(context)?.updateLocation(location);
    await _useLocation(location);
  }

  @override
  void dispose() {
    _request++;
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offset = _reading?.offsetTo(_bearing) ?? _bearing;
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla Finder')),
      body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(20), children: [
        NoorCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_location.label, style: NoorType.cardTitle),
          const SizedBox(height: 6),
          Text(
              '${_location.latitude.toStringAsFixed(4)}, ${_location.longitude.toStringAsFixed(4)}',
              style: NoorType.meta),
          const SizedBox(height: 10),
          OutlinedButton.icon(
              onPressed: _pickLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Update Location')),
        ])),
        const SizedBox(height: 20),
        Text(_status, textAlign: TextAlign.center, style: NoorType.meta),
        const SizedBox(height: 18),
        Semantics(
          liveRegion: true,
          label:
              'Qibla compass: ${_bearing.round()} degrees from true north. ${_aligned ? "Aligned within five degrees" : _status}',
          child: Center(
              child: SizedBox(
                  width: 272,
                  height: 272,
                  child: Stack(alignment: Alignment.center, children: [
                    Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: NoorColors.emeraldDark,
                            border:
                                Border.all(color: NoorColors.gold, width: 3))),
                    ExcludeSemantics(
                        child: Transform.rotate(
                            angle: -(_reading?.heading ?? 0) * math.pi / 180,
                            child: Stack(children: [
                              for (final point in [
                                ('N', Alignment.topCenter),
                                ('E', Alignment.centerRight),
                                ('S', Alignment.bottomCenter),
                                ('W', Alignment.centerLeft)
                              ])
                                Align(
                                    alignment: point.$2,
                                    child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Text(point.$1,
                                            style: NoorType.body.copyWith(
                                                color: Colors.white)))),
                            ]))),
                    Transform.rotate(
                        angle: offset * math.pi / 180,
                        child: const Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                                padding: EdgeInsets.only(top: 46),
                                child: Icon(Icons.navigation,
                                    color: NoorColors.gold, size: 42)))),
                    const Icon(Icons.mosque, color: Colors.white, size: 72),
                  ]))),
        ),
        const SizedBox(height: 20),
        Text('${_bearing.round()}° from true north',
            textAlign: TextAlign.center, style: NoorType.screenTitle),
        const SizedBox(height: 10),
        Text(
            _aligned
                ? 'Aligned with Qibla (±5°)'
                : _reading == null
                    ? 'Use a physical compass to follow this bearing.'
                    : 'Keep the phone flat and turn until the gold arrow points forward.',
            textAlign: TextAlign.center,
            style: NoorType.body),
        const SizedBox(height: 24),
        const NoorCard(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('For a reliable reading', style: NoorType.cardTitle),
          SizedBox(height: 10),
          Text(
              'Keep your phone flat. Remove magnetic cases and move away from metal, speakers and electrical equipment. If accuracy is low, move your phone slowly in a figure eight.',
              style: NoorType.secondary),
          SizedBox(height: 10),
          Text(
              'The direction uses your selected location. A city selection is approximate; update it when travelling.',
              style: NoorType.meta),
        ])),
      ])),
    );
  }
}
