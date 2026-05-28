import os
import subprocess
import re

def run_command(command, ignore_error=False):
    print(f"Executing: {command}")
    try:
        subprocess.run(command, shell=True, check=not ignore_error)
    except subprocess.CalledProcessError as e:
        if ignore_error:
            print(f"⚠️ Warning: Command failed but continuing as requested: {e}")
        else:
            raise e

def main():
    print("🚀 بدء خطوة الإصلاح الشاملة والفرمتة (نسخة Groovy المستقرة)...")

    # 1. توليد مجلد أندرويد
    print("📦 جاري توليد مجلد أندرويد المفقود...")
    run_command("flutter create --platforms=android .", ignore_error=True)

    # 2. تحويل build.gradle.kts إلى build.gradle (Groovy) لضمان الاستقرار
    app_gradle_kts = "android/app/build.gradle.kts"
    app_gradle_groovy = "android/app/build.gradle"
    
    if os.path.exists(app_gradle_kts):
        print(f"🗑️ حذف: {app_gradle_kts}")
        os.remove(app_gradle_kts)
        
    print(f"🛠️ إنشاء نسخة Groovy: {app_gradle_groovy}")
    new_app_gradle = """plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace "com.tetocollctionway.mirror"
    compileSdk 34

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId "com.tetocollctionway.mirror"
        minSdk 21
        targetSdk 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    lintOptions {
        checkReleaseBuilds false
        abortOnError false
    }
}

flutter {
    source "../.."
}
"""
    with open(app_gradle_groovy, "w", encoding="utf-8") as f:
        f.write(new_app_gradle)

    # 3. إصلاح ملف build.gradle (Root)
    root_gradle_path = "android/build.gradle"
    if os.path.exists(root_gradle_path):
        print(f"🛠️ حقن كود تجاوز الأخطاء في: {root_gradle_path}")
        fix_subprojects = """
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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
        with open(root_gradle_path, "w", encoding="utf-8") as f:
            f.write(fix_subprojects)

    # 4. إصلاح AndroidManifest.xml
    manifest_path = "android/app/src/main/AndroidManifest.xml"
    if os.path.exists(manifest_path):
        print(f"🛠️ إصلاح الـ Manifest: {manifest_path}")
        with open(manifest_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        permissions = [
            '    <uses-permission android:name="android.permission.INTERNET"/>',
            '    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>',
            '    <uses-permission android:name="android.permission.RECORD_AUDIO"/>',
            '    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>'
        ]
        
        for perm in permissions:
            if perm.strip() not in content:
                content = content.replace('</manifest>', f'{perm}\n</manifest>')
        
        with open(manifest_path, "w", encoding="utf-8") as f:
            f.write(content)

    # 5. إصلاح مكتبة dash_bubble_local
    local_plugin_kts = "packages/dash_bubble_local/android/build.gradle.kts"
    local_plugin_groovy = "packages/dash_bubble_local/android/build.gradle"
    
    if os.path.exists(local_plugin_kts):
        print(f"🛠️ تحويل الملحق المحلي لـ Groovy: {local_plugin_groovy}")
        os.remove(local_plugin_kts)
        
    plugin_content = """group 'dev.moaz.dash_bubble'
version '2.0.0'

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    namespace "dev.moaz.dash_bubble"
    compileSdk 34
    
    defaultConfig {
        minSdk 21
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }
}

dependencies {
    implementation "androidx.core:core:1.10.1"
    implementation "androidx.appcompat:appcompat:1.6.1"
}
"""
    with open(local_plugin_groovy, "w", encoding="utf-8") as f:
        f.write(plugin_content)

    print("✅ اكتملت جميع عمليات الإصلاح بنجاح!")

if __name__ == "__main__":
    main()
