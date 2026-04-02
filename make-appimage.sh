#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/dkfans/keeperfx/refs/heads/master/res/keeperfx_icon256-24bpp.png
export DEPLOY_QT=1
export QT_DIR=qt6

# Deploy dependencies
quick-sharun ./AppDir/bin/keeperfx-launcher-qt ./AppDir/bin/keeperfx /usr/lib/libopenal.so*
echo 'QT_PLUGIN_PATH=${SHARUN_DIR}/lib/qt6/plugins' >> ./AppDir/.env
echo 'QT_QPA_PLATFORM_PLUGIN_PATH=${SHARUN_DIR}/lib/qt6/plugins/platforms' >> ./AppDir/.env

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
