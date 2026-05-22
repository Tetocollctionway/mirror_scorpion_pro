# Mirror Scorpion - Advanced Protection Rules

# Keep Flutter and its classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Obfuscate everything else possible
-repackageclasses ''
-allowaccessmodification
-overloadaggressively

# Remove all logs for production
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}

# Protect sensitive logic strings
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Prevent reflection on our core services
-keep class com.tetocollctionway.mirror_scorpion_translate.lib.services.** { *; }
-dontwarn io.flutter.embedding.**
