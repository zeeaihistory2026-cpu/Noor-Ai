// Explicit command: flutter test tool/generate_brand_assets_test.dart
// Resizes the supplied artwork without changing its contents.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('render launcher densities from supplied app icon', () async {
    final codec = await ui.instantiateImageCodec(await File('assets/images/app_icon.png').readAsBytes());
    final frame = await codec.getNextFrame();
    final source = frame.image;
    for (final entry in {'mdpi':48, 'hdpi':72, 'xhdpi':96, 'xxhdpi':144, 'xxxhdpi':192}.entries) {
      final size = entry.value;
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawImageRect(source, Rect.fromLTWH(0, 0, source.width.toDouble(), source.height.toDouble()), Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()), Paint()..filterQuality = FilterQuality.high);
      final picture = recorder.endRecording();
      final image = await picture.toImage(size, size);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File('android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png').writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose(); picture.dispose();
    }
    source.dispose(); codec.dispose();
  });
}
