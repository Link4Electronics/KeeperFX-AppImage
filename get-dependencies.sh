#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    libnatpmp   \
    openal      \
    openmpt     \
    python      \
    sdl2        \
    sdl2_image  \
    sdl2_mixer  \
    sdl2_net    \
    tl-expected

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
mv -v bin/keeperfx ../AppDir/bin/keeperfx.exe
cd .. && rm -rf keeperfx

git clone https://github.com/dkfans/QTLauncher
cd QTLauncher
sed find_package(tl-expected REQUIRED) CMakeLists.txt
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=None -DCMAKE_CXX_FLAGS="-Wno-error=unused-result -O3"
make -j$(nproc)
mv -v keeperfx-launcher-qt ../../AppDir/bin
