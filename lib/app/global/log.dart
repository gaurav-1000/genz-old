import "dart:developer";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/foundation.dart";

class Log {
  static void d(String message, {bool display = false}) {
    log(message);
  }

  static void e(dynamic exception, {StackTrace? stackTrace}) {
    if (kReleaseMode && !kIsWeb) {
      FirebaseCrashlytics.instance.recordError(exception, stackTrace ?? StackTrace.current);
    } else {
      log(exception.toString());
      if (stackTrace != null) {
        log(stackTrace.toString());
      }
    }
  }
}
