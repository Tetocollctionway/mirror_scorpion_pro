import sys
import os

manifest_path = sys.argv[1] if len(sys.argv) > 1 else 'android/app/src/main/AndroidManifest.xml'

if not os.path.exists(manifest_path):
    print(f"Error: {manifest_path} not found")
    sys.exit(1)

with open(manifest_path, 'r') as f:
    lines = f.readlines()

permissions = [
    '    <uses-permission android:name="android.permission.INTERNET" />\n',
    '    <uses-permission android:name="android.permission.CAMERA" />\n',
    '    <uses-permission android:name="android.permission.RECORD_AUDIO" />\n',
    '    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />\n',
    '    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />\n',
    '    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />\n',
    '    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />\n',
    '    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />\n'
]

new_lines = []
inserted = False
for line in lines:
    if '<application' in line and not inserted:
        new_lines.extend(permissions)
        inserted = True
    new_lines.append(line)

with open(manifest_path, 'w') as f:
    f.writelines(new_lines)

print(f"Patched {manifest_path} with permissions")
