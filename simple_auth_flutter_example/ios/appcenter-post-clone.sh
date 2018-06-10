#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
set -x

cd ..
git clone -b dev https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH
envman add --key PATH --value $PATH

brew install --HEAD libimobiledevice
brew install ideviceinstaller
brew install ios-deploy

flutter doctor

echo "Installed flutter to `pwd`/flutter"