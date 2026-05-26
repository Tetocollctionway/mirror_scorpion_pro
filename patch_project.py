import os
import subprocess
import re

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
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
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

def fix_kotlin_r_references():
    print("🛠️ جاري إصلاح مراجع R في ملفات Kotlin...")
    pub_cache = os.path.expanduser("~/.pub-cache/hosted/pub.dev")
    if os.path.exists(pub_cache):
        for root, dirs, files in os.walk(pub_cache):
            if "dash_bubble" in root:
                for file in files:
                    if file.endswith(".kt"):
                        filepath = os.path.join(root, file)
                        with open(filepath, 'r') as f:
                            content = f.read()
                        
                        # Use regex for more reliable replacement of R.
                        # Matches R. followed by something, but not preceded by a word character (like dev.moaz.dash_bubble.)
                        original_content = content
                        content = re.sub(r'(?<![a-zA-Z0-9.])R\.(drawable|layout|id|string)', r'dev.moaz.dash_bubble.R.\1', content)
                        
                        if content != original_content:
                            with open(filepath, 'w') as f:
                                f.write(content)
                            print(f"✅ تم إصلاح مراجع R في {file} باستخدام Regex")

if __name__ == "__main__":
    main()
    fix_kotlin_r_references()
