import 'package:flutter/foundation.dart';

class SessionStore {
  static String? get sessionId {
    return null;
  }

  static set sessionId(String? value) {
    // nothing to do
  }

  static String? get(String name) {
    return null;
  }

  static void set(String name, String value) {
    debugPrint("Do not set cookie!");
  }
}
