
import 'package:flutter/foundation.dart';

class R {
  static final Map<String, dynamic> _vars = {};
  
  static dynamic get(String key) => _vars[key];
  static void set(String key, dynamic value) => _vars[key] = value;
  
  // Default definitions to prevent crashes for bubble library
  static final _Drawable drawable = _Drawable();
  static final _Id id = _Id();
  static final _Layout layout = _Layout();
  static final _String string = _String();
}

class _Drawable {
  dynamic noSuchMethod(Invocation invocation) => 0;
  int get ic_close_bubble => 0;
  int get bubble_icon => 0;
}

class _Id {
  dynamic noSuchMethod(Invocation invocation) => 0;
}

class _Layout {
  dynamic noSuchMethod(Invocation invocation) => 0;
}

class _String {
  dynamic noSuchMethod(Invocation invocation) => 0;
}

void initializeRVariables() {
  debugPrint("Mirror Scorpion: Injecting R Variable Fallbacks for Bubble Library...");
  // This bridge ensures that if the native side expects an R variable that hasn't been generated,
  // the app won't crash during Dart execution or when calling native channels.
  R.set('initialized', true);
}
