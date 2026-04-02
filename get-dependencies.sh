#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    libnatpmp

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
make-aur-package lief

# If the application needs to be manually built that has to be done down here
echo "Making Nightly build of KeeperFX..."
echo "---------------------------------------------------------------"
git clone --recursive https://github.com/dkfans/keeperfx
mkdir -p ./AppDir/bin
cd keeperfx
make

git clone https://github.com/dkfans/QTLauncher
cd QTLauncher
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j
