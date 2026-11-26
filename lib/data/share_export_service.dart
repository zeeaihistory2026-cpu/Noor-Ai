import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'share_content.dart';

/// Phase 13 — real PNG export for the Share Studio.
///
/// The share card is a single self-contained widget, so it can be
/// captured faithfully with a RepaintBoundary: render to PNG bytes
/// at 3x, then (a) share through the system share sheet — which is
/// how WhatsApp/Instagram/TikTok/Facebook are reached honestly,
/// one sheet rather than fake per-app buttons — or (b) save to the
/// app documents folder. On web, share_plus falls back to the
/// browser share/download path; if that is unavailable the caller
/// is told honestly instead of pretending a file was written.
class ShareExportService {
  ShareExportService._();

  /// Capture the card as PNG. When [format] is given the PNG is
  /// rendered at the platform's export pixel width (e.g. 1080 for
  /// Instagram/TikTok) by scaling the pixel ratio off the live
  /// boundary size, so a 4:5 card really exports 1080×1350.
  static Future<Uint8List?> capturePng(
    GlobalKey boundaryKey, {
    ShareFormatOption? format,
  }) async {
    await WidgetsBinding.instance.endOfFrame;
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null || !boundary.hasSize || boundary.size.isEmpty) {
      return null;
    }
    var pixelRatio = 3.0;
    if (format != null && boundary.size.width > 0) {
      pixelRatio = format.exportWidth / boundary.size.width;
    }
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    ui.Image output = image;
    try {
      // Raster bounds round up; a 9:16 layout can otherwise become 1921px.
      if (format != null && (image.width != format.exportWidth || image.height != format.exportHeight)) {
        final recorder = ui.PictureRecorder();
        final canvas = ui.Canvas(recorder);
        canvas.drawImageRect(image,
            ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
            ui.Rect.fromLTWH(0, 0, format.exportWidth.toDouble(), format.exportHeight.toDouble()),
            ui.Paint()..filterQuality = ui.FilterQuality.high);
        final picture = recorder.endRecording();
        try {
          output = await picture.toImage(format.exportWidth, format.exportHeight);
        } finally {
          picture.dispose();
        }
      }
      final data = await output.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      if (!identical(output, image)) output.dispose();
      image.dispose();
    }
  }

  static Future<bool> shareCard(
    GlobalKey boundaryKey, {
    ShareFormatOption? format,
    String? text,
  }) async {
    final bytes = await capturePng(boundaryKey, format: format);
    if (bytes == null) return false;
    final name = format == null ? 'noor_share.png' : 'noor_${format.id}.png';
    final XFile xfile;
    if (kIsWeb) {
      xfile = XFile.fromData(bytes, name: name, mimeType: 'image/png');
    } else {
      final file = await _writeTemp(bytes, name);
      xfile = XFile(file.path, mimeType: 'image/png');
    }
    final result = await SharePlus.instance.share(ShareParams(
      files: [xfile],
      text: text ?? 'Shared with MuslimGo',
      sharePositionOrigin: _shareOrigin(boundaryKey),
    ));
    return result.status != ShareResultStatus.unavailable;
  }

  /// Save into app documents (visible in Files on iOS; app folder
  /// on Android). Returns the file path, or null when storage is
  /// not available on this platform (e.g. web — caller says so).
  static Future<String?> saveCard(
    GlobalKey boundaryKey, {
    ShareFormatOption? format,
  }) async {
    if (kIsWeb) return null;
    final bytes = await capturePng(boundaryKey, format: format);
    if (bytes == null) return null;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const MethodChannel('com.noorai.com/export')
          .invokeMethod<String>('saveImage', {
        'bytes': bytes,
        'name': 'MuslimGo_${DateTime.now().millisecondsSinceEpoch}.png',
      });
    }
    final dir = await getApplicationDocumentsDirectory();
    final suffix = format == null ? '' : '_${format.id}';
    final file = File('${dir.path}/noor_share$suffix'
        '_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  static Future<File> _writeTemp(Uint8List bytes, [String? name]) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${name ?? 'noor_share'}'
        '_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Rect? _shareOrigin(GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}
