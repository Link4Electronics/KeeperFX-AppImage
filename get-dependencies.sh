#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake          \
    enet           \
    kvantum        \
    libnatpmp      \
    libspng        \
    luajit         \
    lxqt-qtplugin  \
    miniupnpc      \
    minizip        \
    openal         \
    python         \
    qt6ct          \
    sdl2           \
    sdl2_image     \
    sdl2_mixer     \
    sdl2_net       \
    tl-expected    \
    vulkan-headers

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

# Comment this out if you need an AUR package
make-aur-package lief
#make-aur-package openmpt

# If the application needs to be manually built that has to be done down here
echo "Making Nightly build of KeeperFX..."
echo "---------------------------------------------------------------"
#git clone --recursive https://github.com/dkfans/keeperfx
#mkdir -p ./AppDir/bin
#cd keeperfx
#sed -i 's/-Werror/-Wno-error/g' linux.mk
if [ "$ARCH" = "aarch64" ]; then
    sed -i 's/x86-64/armv8-a/g' Makefile
    sed -i 's/x86-64/armv8-a/g' linux.mk
fi
#make -f linux.mk all -j$(nproc)
#mv -v bin/keeperfx ../AppDir/bin/keeperfx.exe
#cd .. && rm -rf keeperfx

git clone https://github.com/dkfans/QTLauncher
cd QTLauncher
sed -i '2i find_package(tl-expected REQUIRED)' CMakeLists.txt
sed -i -e 's/\/keeperfx\.exe/\/keeperfx/g' \
       -e '/params\.prepend("wine");/d' \
       -e '/process->start("wine", params);/d' src/game.cpp
sed -i 's/\/keeperfx\.exe/\/keeperfx/g' src/kfxversion.cpp
sed -i 's/\/keeperfx\.exe/\/keeperfx/g' src/launchermainwindow.cpp
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=None -DCMAKE_CXX_FLAGS="-Wno-error=unused-result -O3"
make -j$(nproc)
mv -v keeperfx-launcher-qt ../../AppDir/bin
