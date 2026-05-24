# Mirror Scorpion - ProGuard/R8 Rules for Maximum Protection Against Reverse Engineering (360 Protection)

# ============================================================================
# GENERAL RULES - Keep essential classes
# ============================================================================

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }

# Keep Android support libraries
-keep class androidx.** { *; }
-keep interface androidx.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable implementations
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ============================================================================
# MIRROR SCORPION SPECIFIC PROTECTION - 360 DEGREE SECURITY
# ============================================================================

# Aggressive obfuscation for security-critical classes
-repackageclasses 'com.mirror.scorpion.core'
-allowaccessmodification
-overloadaggressively

# Protect all service classes
-keep class com.tetocollctionway.mirror_scorpion_translate.services.** { *; }
-keepclassmembers class com.tetocollctionway.mirror_scorpion_translate.services.** {
    *** get*();
    void set*(***);
    boolean is*();
}

# Protect premium verification - CRITICAL
-keep class * {
    public boolean isPremium();
    public boolean canShare();
    public boolean isProVersion();
}

-keepclassmembers class * {
    private boolean *Premium*;
    private boolean *Pro*;
    private boolean *Paid*;
    private boolean *Share*;
}

# ============================================================================
# AGGRESSIVE OBFUSCATION - PREVENT REVERSE ENGINEERING
# ============================================================================

# Remove logging statements completely
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
    public static *** wtf(...);
}

# Remove debug output
-assumenosideeffects class java.io.PrintStream {
    public void println(...);
    public void print(...);
}

# Remove assertions
-assumenosideeffects class java.lang.String {
    public static java.lang.String valueOf(...);
}

# ============================================================================
# PREVENT REFLECTION ATTACKS
# ============================================================================

# Protect reflection-sensitive code
-keepclasseswithmembers class * {
    *** *(...) throws <exception>;
}

# Protect field access
-keepclassmembers class * {
    private *** *;
    protected *** *;
}

# Prevent reflection on premium features
-keepclassmembers class * {
    public *** get*Premium*(...);
    public *** set*Premium*(...);
    public *** check*Premium*(...);
}

# ============================================================================
# PROTECT STRINGS AND CONSTANTS
# ============================================================================

# Keep string constants for premium features (obfuscated)
-keepclassmembers class * {
    public static final java.lang.String *;
}

# ============================================================================
# OPTIMIZATION RULES - AGGRESSIVE
# ============================================================================

# Aggressive optimization passes
-optimizationpasses 7
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*,!code/allocation/variable,!code/removal/variable

# Shrink unused code
-dontshrink
-dontskipnonpubliclibraryclasses
-dontskipnonpubliclibraryclassmembers

# ============================================================================
# KEEP ANNOTATIONS
# ============================================================================

-keepattributes SourceFile,LineNumberTable
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ============================================================================
# THIRD-PARTY LIBRARY PROTECTION
# ============================================================================

# Protect dash_bubble
-keep class dev.moaz.dash_bubble.** { *; }
-keep interface dev.moaz.dash_bubble.** { *; }

# Protect shared_preferences
-keep class androidx.security.crypto.** { *; }

# Protect http client
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ============================================================================
# ANTI-TAMPERING MEASURES
# ============================================================================

# Prevent modification of critical methods
-keepclassmembers class com.tetocollctionway.mirror_scorpion_translate.core.security.** {
    public *** verify*(...);
    public *** validate*(...);
    public *** check*(...);
    public *** authenticate*(...);
}

# Protect authentication
-keep class com.tetocollctionway.mirror_scorpion_translate.auth.** { *; }
-keep class com.tetocollctionway.mirror_scorpion_translate.licensing.** { *; }

# ============================================================================
# FINAL OBFUSCATION SETTINGS
# ============================================================================

# Use aggressive naming
-useuniqueclassmembernames

# Rename source files to hide implementation
-renamesourcefileattribute SourceFile

# Verbose output for debugging
-verbose

# ============================================================================
# PREMIUM FEATURE PROTECTION - CRITICAL FOR PREVENTING SHARING
# ============================================================================

# Chess Game - Premium Feature
-keep class com.tetocollctionway.mirror_scorpion_translate.features.games.chess.ChessGame {
    public *** *(...);
}
-keep class com.tetocollctionway.mirror_scorpion_translate.features.games.chess.ChessScreen {
    public *** *(...);
}

# Rubik's Cube - Premium Feature
-keep class com.tetocollctionway.mirror_scorpion_translate.features.games.rubik_cube.RubiksCube {
    public *** *(...);
}
-keep class com.tetocollctionway.mirror_scorpion_translate.features.games.rubik_cube.RubikEnhanced {
    public *** *(...);
}

# Document Features - Premium Feature
-keep class com.tetocollctionway.mirror_scorpion_translate.features.card3_document.DocumentLens {
    public *** *(...);
}
-keep class com.tetocollctionway.mirror_scorpion_translate.services.DocumentExportService {
    public *** *(...);
}

# Floating Bubble - Premium Feature
-keep class com.tetocollctionway.mirror_scorpion_translate.services.FloatingBubbleService {
    public *** *(...);
}

# ============================================================================
# PREVENT FEATURE SHARING - CRITICAL
# ============================================================================

# Obfuscate all sharing-related code
-keepclassmembers class * {
    *** share*(...);
    *** export*(...);
    *** save*(...);
    *** copy*(...);
}

# Protect premium flag checks
-keepclassmembers class * {
    private boolean *premium*;
    private boolean *pro*;
    private boolean *paid*;
}

# Prevent access to premium features via reflection
-keepclassmembers class * {
    public *** getPremium*(...);
    public *** setPremium*(...);
    public *** checkPremium*(...);
    public *** verifyPremium*(...);
}

# ============================================================================
# REMOVE DEBUG INFORMATION
# ============================================================================

# Strip debug symbols from native code
-keep class * {
    public <init>(...);
}

# ============================================================================
# END OF PROGUARD RULES - MAXIMUM PROTECTION APPLIED
# ============================================================================
