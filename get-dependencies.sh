#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    7zip           \
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

# If the application needs to be manually built that has to be done down here
echo "Making Nightly build of KeeperFX..."
echo "---------------------------------------------------------------"
REPO="https://github.com/dkfans/keeperfx"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone --recursive "$REPO" ./keeperfx
echo "$VERSION" > ~/version
mkdir -p ./AppDir/bin

wget https://github.com/dkfans/keeperfx/releases/download/v1.3.1/keeperfx_1_3_1_complete.7z
#bsdtar -xvf keeperfx_1_3_1_complete.7z -C ./AppDir/bin --include="*/" --include="*.map"
7z x keeperfx_1_3_1_complete.7z -o./AppDir/bin '-i!*/*' '-i!*.map' '-x!*'
wget https://keeperfx.net/download/alpha/keeperfx-1_3_1_4948_Alpha-patch.7z
#bsdtar -xvf keeperfx-1_3_1_4948_Alpha-patch.7z -C ./AppDir/bin --include="*/" --include="*.map"
7z x keeperfx-1_3_1_4948_Alpha-patch.7z -o./AppDir/bin '-i!*/*' '-i!*.map' '-x!*'
rm -f *.7z

cd keeperfx
mkdir -p deps/astronomy deps/centijson deps/enet6 deps/libcurl
curl -L -o deps/enet6-lin64.tar.gz "https://github.com/dkfans/kfx-deps/releases/download/20260310/enet6-lin64.tar.gz"
tar -xzvf deps/enet6-lin64.tar.gz -C deps/enet6
curl -L -o deps/centijson-lin64.tar.gz "https://github.com/dkfans/kfx-deps/releases/download/20260310/centijson-lin64.tar.gz"
tar -xzvf deps/centijson-lin64.tar.gz -C deps/centijson

sed -i 's/-Werror/-Wno-error/g' linux.mk
if [ "$ARCH" = "aarch64" ]; then
    sed -i 's/x86-64/armv8-a/g' Makefile
    sed -i 's/x86-64/armv8-a/g' linux.mk
    make -f linux.mk CXX="g++ -fsigned-char -Wno-error=narrowing" CC="gcc -fsigned-char" all -j$(nproc)
else
make -f linux.mk all -j$(nproc)
fi
mv -v bin/keeperfx ../AppDir/bin
cd .. && rm -rf keeperfx
echo "Making Nightly build of QTLauncher..."
echo "---------------------------------------------------------------"
git clone https://github.com/dkfans/QTLauncher
cd QTLauncher
patch -Np1 -i ../launcherfix.patch
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=None -DCMAKE_CXX_FLAGS="-Wno-error=unused-result -O3"
make -j$(nproc)
mv -v keeperfx-launcher-qt ../../AppDir/bin
