#!/bin/bash
# Stage tracked files only — avoids accidentally committing secrets or untracked files.
git add -u
git commit -m "تحديث الكروت والمسارات - أدهم"
git push origin main
echo "تم رفع المركب إلى جيت هب بنجاح!"
