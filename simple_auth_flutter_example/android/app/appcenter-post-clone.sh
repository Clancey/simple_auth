#!/usr/bin/env bash
# fail if any commands fails

cd ..

set -e
# debug log
set -x

cd ..
git clone -b dev https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH

flutter doctor

echo "Installed flutter to `pwd`/flutter"
flutter build apk --release
mkdir -p android/app/build/outputs/apk/; mv build/app/outputs/apk/release/app-release.apk $_