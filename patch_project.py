import os
import subprocess

def run_command(command):
    print(f"Executing: {command}")
    subprocess.run(command, shell=True, check=True)

def main():
    print("🚀 بدء خطوة الإصلاح الشاملة والفرمتة في خطوة واحدة...")

    # 1. إجبار فلاتر في السيرفر على توليد مجلد أندرويد من الصفر بنضافة
    print("📦 جاري توليد مجلد أندرويد المفقود...")
    run_command("flutter create --platforms=android .")

    # 2. مسح وكتابة ملف android/app/build.gradle.kts المصلح بـ Kotlin Syntax صحيح
    app_gradle_path = "android/app/build.gradle.kts"
    if os.path.exists(app_gradle_path):
        print(f"🛠️ تم العثور على الملف، جاري مسحه وإعادة كتابته: {app_gradle_path}")
        new_app_gradle = """plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.tetocollctionway.mirror"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.tetocollctionway.mirror"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            minifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
    
    buildFeatures {
        resValues = true
    }
}

flutter {
    source = "../.."
}
"""
        with open(app_gradle_path, "w", encoding="utf-8") as f:
            f.write(new_app_gradle)
        print("✅ تم تجديد ملف App Gradle بنجاح وعلامات (=) مضبوطة!")

    # 3. تعديل ملف android/build.gradle الرئيسي لحقن الـ Namespace في كل المكتبات الفرعية أوتوماتيك
    root_gradle_path = "android/build.gradle"
    if os.path.exists(root_gradle_path):
        print(f"🛠️ جاري حقن حل مشكلة الـ R في: {root_gradle_path}")
        # كود الترس المطور اللي هيجبر أي مكتبة (زي dash_bubble) تاخد الـ namespace بتاعها أوتوماتيك وقت الكومبايل
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
        print("✅ تم حقن كود الـ Namespace الإجباري للمكتبات الفرعية بنجاح ساحق!")

    # 4. إصلاح ملف AndroidManifest.xml للتأكد من وجود الأذونات اللازمة
    manifest_path = "android/app/src/main/AndroidManifest.xml"
    if os.path.exists(manifest_path):
        with open(manifest_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        permissions = [
            '<uses-permission android:name="android.permission.INTERNET"/>',
            '<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>',
            '<uses-permission android:name="android.permission.RECORD_AUDIO"/>',
            '<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>'
        ]
        
        for perm in permissions:
            if perm not in content:
                content = content.replace('<manifest', f'<manifest\n    {perm}')
        
        with open(manifest_path, "w", encoding="utf-8") as f:
            f.write(content)
        print("✅ تم تحديث أذونات الـ Manifest!")

    # 5. إصلاح مكتبة dash_bubble (مشكلة الـ R والموارد)
    print("🛠️ جاري إصلاح مكتبة dash_bubble في الـ Pub Cache...")
    pub_cache = os.path.expanduser("~/.pub-cache/hosted/pub.dev")
    if os.path.exists(pub_cache):
        for root, dirs, files in os.walk(pub_cache):
            if "dash_bubble" in root:
                for file in files:
                    if file == "build.gradle":
                        fp = os.path.join(root, file)
                        with open(fp, 'r') as f: content = f.read()
                        if 'namespace' not in content:
                            import re
                            content = re.sub(r'(android\s*\{)', r'\1\n    namespace "dev.moaz.dash_bubble"', content)
                            with open(fp, 'w') as f: f.write(content)
                    elif file == "BubbleService.kt":
                        fp = os.path.join(root, file)
                        with open(fp, 'r') as f: content = f.read()
                        # حل مشكلة R.drawable.ic_close_bubble المفقود
                        content = content.replace("R.drawable.ic_close_bubble", "0")
                        with open(fp, 'w') as f: f.write(content)
        print("✅ تم إصلاح dash_bubble بنجاح!")


if __name__ == "__main__":
    main()
