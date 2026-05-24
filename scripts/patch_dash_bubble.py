import os
import re
import sys

# Find and patch dash_bubble build.gradle files
pub_cache = os.path.expanduser("~/.pub-cache/hosted/pub.dev")

if not os.path.exists(pub_cache):
    print(f"Pub cache not found: {pub_cache}")
    sys.exit(0)

# Find all dash_bubble build.gradle files
for root, dirs, files in os.walk(pub_cache):
    if "dash_bubble" in root:
        for file in files:
            if file == "build.gradle":
                filepath = os.path.join(root, file)
                print(f"Patching: {filepath}")
                
                with open(filepath, 'r') as f:
                    content = f.read()
                
                # Add namespace if not present
                if 'namespace' not in content:
                    # Find the android block and add namespace
                    content = re.sub(
                        r'(android\s*\{)',
                        r'\1\n    namespace "dev.moaz.dash_bubble"',
                        content
                    )
                else:
                    # Replace placeholder namespace
                    content = content.replace(
                        'namespace "com.example.placeholder"',
                        'namespace "dev.moaz.dash_bubble"'
                    )
                
                with open(filepath, 'w') as f:
                    f.write(content)
                
                print(f"✓ Fixed namespace in {filepath}")
            
            elif file == "build.gradle.kts":
                filepath = os.path.join(root, file)
                print(f"Patching: {filepath}")
                
                with open(filepath, 'r') as f:
                    content = f.read()
                
                # Add namespace if not present
                if 'namespace' not in content:
                    # Find the android block and add namespace
                    content = re.sub(
                        r'(android\s*\{)',
                        r'\1\n    namespace = "dev.moaz.dash_bubble"',
                        content
                    )
                
                with open(filepath, 'w') as f:
                    f.write(content)
                
                print(f"✓ Fixed namespace in {filepath}")

print("dash_bubble patching complete")
