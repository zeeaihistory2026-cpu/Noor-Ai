import 'package:flutter/services.dart';

class CompassReading {
  const CompassReading(this.heading, this.pitch, this.roll, this.accuracy);
  factory CompassReading.fromMap(Map data) => CompassReading(
      (data['heading'] as num).toDouble(),
      (data['pitch'] as num).toDouble(),
      (data['roll'] as num).toDouble(),
      data['accuracy'] as int);
  final double heading;
  final double pitch;
  final double roll;
  final int accuracy;
  double offsetTo(double bearing) => (bearing - heading + 540) % 360 - 180;
  bool alignedWith(double bearing) =>
      accuracy >= 2 &&
      pitch.abs() < 30 &&
      roll.abs() < 30 &&
      offsetTo(bearing).abs() <= 5;
}

class CompassService {
  static Stream<CompassReading> readings(double latitude, double longitude) =>
      const EventChannel('com.noorai.com/compass').receiveBroadcastStream({
        'latitude': latitude,
        'longitude': longitude
      }).map((data) => CompassReading.fromMap(data as Map));
}
