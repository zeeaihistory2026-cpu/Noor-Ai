// Phase 8 — real local notifications facade.
//
// Conditional export: native/desktop (dart:io available) get the
// flutter_local_notifications implementation; web gets the no-op
// stub so `flutter build web` never pulls platform channels it
// cannot use. Callers only ever see NoorNotifications.
export 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_io.dart';
