#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    libnatpmp  \
    openal     \
    openmpt    \
    python     \
    sdl2       \
    sdl2_image \
    sdl2_mixer \
    sdl2_net

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

# Comment this out if you need an AUR package
make-aur-package lief

# If the application needs to be manually built that has to be done down here
echo "Making Nightly build of KeeperFX..."
echo "---------------------------------------------------------------"
git clone --recursive https://github.com/dkfans/keeperfx
mkdir -p ./AppDir/bin
cd keeperfx
make -f linux.mk all -j$(nproc)

git clone https://github.com/dkfans/QTLauncher
cd QTLauncher
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
