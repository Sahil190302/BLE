import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ErrorHandler {
  static String prettyException(String prefix, dynamic e) {
    if (e is FlutterBluePlusException) {
      return "$prefix: ${e.description ?? e.code}";
    }
    if (e is TimeoutException) {
      return "$prefix: Operation timed out. Move closer to the device.";
    }
    return "$prefix: ${e.toString()}";
  }
}



class DebugLog {
  static void d(String tag, String message) {
    if (kDebugMode) {
      debugPrint("🔵 [$tag] $message");
    }
  }

  static void w(String tag, String message) {
    if (kDebugMode) {
      debugPrint("🟠 [$tag] $message");
    }
  }

  static void e(String tag, String message) {
    if (kDebugMode) {
      debugPrint("🔴 [$tag] $message");
    }
  }
}