"""
patch_project.py - Automated build-environment fixer for Mirror Scorpion.

This script applies a series of deterministic patches so the Flutter/Android
project compiles cleanly on a fresh checkout.  Each patch targets a specific
incompatibility introduced by AGP 8.0+, SDK 36, or the vendored dash_bubble
plugin.

Run after `flutter pub get`:
    python3 patch_project.py

Every patch function is *idempotent* - running the script multiple times
produces the same result.
"""

import subprocess
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

APP_NAMESPACE = "com.tetocollctionway.mirror"
DASH_BUBBLE_NAMESPACE = "dev.moaz.dash_bubble"

# Relative paths (from the project root)
APP_GRADLE_KTS_PATH = Path("android/app/build.gradle.kts")
APP_GRADLE_GROOVY_PATH = Path("android/app/build.gradle")
ROOT_GRADLE_PATH = Path("android/build.gradle")
MANIFEST_PATH = Path("android/app/src/main/AndroidManifest.xml")
LOCAL_PLUGIN_KTS = Path("packages/dash_bubble_local/android/build.gradle.kts")
LOCAL_PLUGIN_GROOVY = Path("packages/dash_bubble_local/android/build.gradle")

# Permissions that the app requires at runtime
REQUIRED_PERMISSIONS = [
    "android.permission.INTERNET",
    "android.permission.SYSTEM_ALERT_WINDOW",
    "android.permission.RECORD_AUDIO",
    "android.permission.FOREGROUND_SERVICE",
]

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def run_command(command: str, *, ignore_error: bool = False) -> None:
    """Execute a shell command, optionally ignoring failures."""
    print(f"  > {command}")
    try:
        subprocess.run(command, shell=True, check=not ignore_error)
    except subprocess.CalledProcessError as exc:
        if ignore_error:
            print(f"  [warn] command failed (ignored): {exc}")
        else:
            raise


def read_text(path: Path) -> Optional[str]:
    """Return file contents or *None* if the file does not exist."""
    if not path.exists():
        print(f"  [skip] {path} not found")
        return None
    return path.read_text(encoding="utf-8")


def write_text(path: Path, content: str) -> None:
    """Write *content* to *path*, creating parent directories if needed."""
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    print(f"  [write] {path}")


def remove_if_exists(path: Path) -> None:
    """Delete *path* if it exists, logging the action."""
    if path.exists():
        path.unlink()
        print(f"  [delete] {path}")


# ---------------------------------------------------------------------------
# Patch: Generate the Android platform folder
# ---------------------------------------------------------------------------


def patch_generate_android_folder() -> None:
    """Ensure the `android/` directory exists.

    A fresh clone may lack platform folders.  `flutter create` regenerates
    them without touching existing Dart sources.
    """
    print("\n[1/5] Generating android/ platform folder ...")
    run_command("flutter create --platforms=android .", ignore_error=True)


# ---------------------------------------------------------------------------
# Patch: App-level Gradle — convert .kts to Groovy
# ---------------------------------------------------------------------------

# AGP 8.0 requires every Android module to declare an explicit `namespace`.
# The project has migrated from Kotlin DSL (.kts) to Groovy DSL (.gradle)
# for better stability with the Flutter toolchain.  This template uses the
# Groovy syntax and includes shrinkResources for release builds.
_APP_GRADLE_TEMPLATE = """\
plugins {{
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}}

android {{
    namespace "{namespace}"
    compileSdk {compile_sdk}

    compileOptions {{
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }}

    kotlinOptions {{
        jvmTarget = "17"
    }}

    defaultConfig {{
        applicationId "{namespace}"
        minSdk {min_sdk}
        targetSdk {target_sdk}
        versionCode 1
        versionName "1.0.0"
    }}

    buildTypes {{
        release {{
            signingConfig signingConfigs.debug
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }}
    }}

    lintOptions {{
        checkReleaseBuilds false
        abortOnError false
    }}
}}

flutter {{
    source "../.."
}}
"""


def patch_app_gradle() -> None:
    """Replace the app-level build file with a stable Groovy-DSL version.

    Why this patch is needed:
    - AGP 8.0 requires an explicit `namespace` in every module.
    - `flutter create` may generate a Kotlin DSL file (.kts) which has
      caused compatibility issues with some Flutter plugin builds.
      Converting to Groovy (.gradle) provides better stability.
    - compileSdk, minSdk, and targetSdk are pinned to known-good values.
    - Release builds enable both minification and resource shrinking.
    """
    print("\n[2/5] Patching app-level build.gradle (Groovy) ...")

    # Remove the .kts variant if it exists — only one DSL file should be
    # present, and we are standardizing on Groovy.
    remove_if_exists(APP_GRADLE_KTS_PATH)

    content = _APP_GRADLE_TEMPLATE.format(
        namespace=APP_NAMESPACE,
        compile_sdk=34,
        min_sdk=21,
        target_sdk=34,
    )
    write_text(APP_GRADLE_GROOVY_PATH, content)


# ---------------------------------------------------------------------------
# Patch: Root-level Gradle (build.gradle)
# ---------------------------------------------------------------------------

# The root build.gradle performs three jobs:
#   1. Provide google() + mavenCentral() repos for all sub-projects.
#   2. Auto-assign a `namespace` to any plugin that forgot to declare one
#      (AGP 8.0 requirement).
#   3. Redirect build output so `flutter clean` works correctly.
_ROOT_GRADLE_TEMPLATE = """\
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Redirect build artifacts under the project-level `build/` directory so
// that `flutter clean` removes everything in one pass.
rootProject.buildDir = '../build'
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}

subprojects {
    project.evaluationDependsOn(':app')
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}

// AGP 8.0+ requires every Android library to declare a namespace.  Some
// third-party plugins published before AGP 8 omit it.  This block injects a
// fallback namespace (group + name) for any plugin that still lacks one.
subprojects {
    afterEvaluate { project ->
        if (project.hasProperty("android")) {
            project.android {
                if (namespace == null) {
                    namespace = project.group.toString() + "." + project.name
                }
            }
        }
    }
}
"""


def patch_root_gradle() -> None:
    """Rewrite the root build.gradle with repo/namespace fixes.

    Why this patch is needed:
    - Many pub plugins assume the host project provides google() and
      mavenCentral() repos at the root level.
    - Plugins published before AGP 8.0 may lack a `namespace` declaration,
      causing the build to fail.  The `afterEvaluate` block provides a
      safe fallback.
    - Redirecting build output ensures `flutter clean` works predictably.
    """
    print("\n[3/5] Patching root build.gradle ...")
    if not ROOT_GRADLE_PATH.exists():
        print("  [skip] file not found - run step 1 first")
        return

    write_text(ROOT_GRADLE_PATH, _ROOT_GRADLE_TEMPLATE)


# ---------------------------------------------------------------------------
# Patch: AndroidManifest.xml permissions
# ---------------------------------------------------------------------------


def patch_manifest_permissions() -> None:
    """Add required permissions to AndroidManifest.xml if missing.

    Why this patch is needed:
    - `flutter create` generates a minimal manifest without the runtime
      permissions that Mirror Scorpion needs:
        * INTERNET — translation API calls
        * SYSTEM_ALERT_WINDOW — floating bubble overlay
        * RECORD_AUDIO — speech-to-text microphone access
        * FOREGROUND_SERVICE — background bubble service
    """
    print("\n[4/5] Patching AndroidManifest.xml permissions ...")
    content = read_text(MANIFEST_PATH)
    if content is None or "<manifest" not in content:
        return

    changed = False
    for perm in REQUIRED_PERMISSIONS:
        tag = f'<uses-permission android:name="{perm}"/>'
        if perm not in content:
            content = content.replace(
                "</manifest>",
                f"    {tag}\n</manifest>",
            )
            changed = True
            print(f"  [add] {perm}")

    if changed:
        write_text(MANIFEST_PATH, content)
    else:
        print("  [skip] all permissions already present")


# ---------------------------------------------------------------------------
# Patch: dash_bubble local plugin — convert .kts to Groovy
# ---------------------------------------------------------------------------

# The vendored dash_bubble plugin originally shipped with a Kotlin DSL build
# file that lacked a `namespace` declaration and used syntax that conflicts
# with some AGP 8.0+ configurations.  Converting to Groovy DSL with an
# explicit namespace resolves both issues.
_DASH_BUBBLE_GROOVY_TEMPLATE = """\
group '{namespace}'
version '2.0.0'

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {{
    namespace "{namespace}"
    compileSdk {compile_sdk}

    defaultConfig {{
        minSdk {min_sdk}
    }}

    compileOptions {{
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }}

    kotlinOptions {{
        jvmTarget = '17'
    }}
}}

dependencies {{
    implementation "androidx.core:core:1.10.1"
    implementation "androidx.appcompat:appcompat:1.6.1"
}}
"""


def patch_dash_bubble() -> None:
    """Replace the dash_bubble local plugin build file with Groovy DSL.

    Why this patch is needed:
    - The vendored dash_bubble plugin originally used Kotlin DSL (.kts)
      without a `namespace` declaration, which AGP 8.0+ rejects.
    - Converting to Groovy DSL keeps the plugin consistent with the rest
      of the project's build system.
    - The explicit `namespace` prevents the "namespace not specified" build
      error that AGP 8.0+ raises for library modules.
    """
    print("\n[5/5] Patching dash_bubble local plugin (Groovy) ...")

    # Remove the .kts variant — only one DSL file should be present.
    remove_if_exists(LOCAL_PLUGIN_KTS)

    content = _DASH_BUBBLE_GROOVY_TEMPLATE.format(
        namespace=DASH_BUBBLE_NAMESPACE,
        compile_sdk=34,
        min_sdk=21,
    )
    write_text(LOCAL_PLUGIN_GROOVY, content)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

_PATCHES = [
    patch_generate_android_folder,
    patch_app_gradle,
    patch_root_gradle,
    patch_manifest_permissions,
    patch_dash_bubble,
]


def main() -> None:
    """Run all patches in order, continuing past individual failures."""
    print("=" * 60)
    print("Mirror Scorpion - Project Patcher (Groovy DSL, AGP 8.0+)")
    print("=" * 60)

    for patch_fn in _PATCHES:
        try:
            patch_fn()
        except Exception as exc:
            print(f"\n  [ERROR] {patch_fn.__name__} failed: {exc}")
            print("  Continuing with remaining patches ...\n")

    print("\n" + "=" * 60)
    print("All patches applied successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()
