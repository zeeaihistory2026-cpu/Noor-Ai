import 'dart:ui';
import 'package:flutter/material.dart';
import 'app.dart';
import 'theme/noor_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Graceful Widget Error Boundary (prevents red screen of death in UI)
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: NoorColors.gold, size: 36),
              const SizedBox(height: 8),
              Text(
                'Something went wrong while rendering this section.',
                textAlign: TextAlign.center,
                style: NoorType.meta.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Synchronous Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  // Asynchronous uncaught platform/isolate errors
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('Uncaught Platform Error: $error\n$stack');
    return true;
  };

  runApp(const NoorApp());
}
