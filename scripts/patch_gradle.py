import sys
import os
import re

filepath = sys.argv[1] if len(sys.argv) > 1 else 'android/app/build.gradle.kts'

if not os.path.exists(filepath):
    print(f"File not found: {filepath}")
    sys.exit(0)

with open(filepath, 'r') as f:
    content = f.read()

# 1. Patch minSdk
content = content.replace('minSdk = flutter.minSdkVersion', 'minSdk = 21')

# 2. Fix compileSdk and targetSdk syntax for Kotlin DSL
# Using 36 as requested by the latest plugins
content = re.sub(r'compileSdk\s+\d+', 'compileSdk = 36', content)
content = re.sub(r'targetSdk\s+\d+', 'targetSdk = 35', content)
content = re.sub(r'compileSdkVersion\s+\d+', 'compileSdkVersion = 36', content)
content = re.sub(r'targetSdkVersion\s+\d+', 'targetSdkVersion = 35', content)

# 3. Force isMinifyEnabled to false wherever it appears
content = content.replace('isMinifyEnabled = true', 'isMinifyEnabled = false')

# 4. If no isMinifyEnabled found at all, add it
if 'isMinifyEnabled' not in content:
    content = content.replace(
        'signingConfig = signingConfigs.debug',
        'signingConfig = signingConfigs.debug\n            isMinifyEnabled = false'
    )

# 5. Add proguardFiles with ML Kit keep rules
if 'proguardFiles' not in content:
    content = content.replace(
        'isMinifyEnabled = false',
        'isMinifyEnabled = false\n            proguardFiles(\n                getDefaultProguardFile("proguard-android-optimize.txt"),\n                "proguard-rules.pro"\n            )'
    )

# 6. Add shrinkResources = false
content = content.replace('shrinkResources = true', 'shrinkResources = false')
if 'shrinkResources' not in content:
    content = content.replace(
        'isMinifyEnabled = false',
        'isMinifyEnabled = false\n            shrinkResources = false'
    )

with open(filepath, 'w') as f:
    f.write(content)

# تظبيط قواعد Proguard لـ ML Kit لحل مشكلة الكلاسات المفقودة تماماً
proguard_path = os.path.join(os.path.dirname(filepath), 'proguard-rules.pro')
with open(proguard_path, 'w') as f:
    f.write('''# ML Kit rules
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# تجاهل أخطاء الكلاسات المفقودة للغات الإضافية أثناء الـ Minification
-ignorewarnings
''')

print(f"Patched {filepath}")
print(f"Created {proguard_path}")
