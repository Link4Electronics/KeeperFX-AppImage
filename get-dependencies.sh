#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake          \
    kvantum        \
    libnatpmp      \
    libspng        \
    luajit         \
    lxqt-qtplugin  \
    miniupnpc      \
    minizip        \
    ninja          \
    openal         \
    qt6ct          \
    sdl3_image     \
    sdl3_mixer

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini qt6-base-mini

echo "Building dependencies..."
echo "---------------------------------------------------------------"
git clone --depth 1 https://github.com/SirLynix/enet6
cmake -S ./enet6 -B ./enet6-build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_SHARED_LIBS=OFF
cmake --build ./enet6-build
cmake --install ./enet6-build
rm -rf ./enet6 ./enet6-build

git clone --depth 1 https://github.com/mity/centijson
cmake -S ./centijson -B ./centijson-build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTS=OFF \
      -DBUILD_UTILS=OFF
cmake --build ./centijson-build
cp ./centijson/src/*.h /usr/include/
cp "$(find ./centijson-build -name libjson.a -print -quit)" /usr/lib/libjson.a
rm -rf ./centijson ./centijson-build

git clone --depth 1 https://github.com/cosinekitty/astronomy
cc -O2 -c ./astronomy/source/c/astronomy.c -o ./astronomy.o
ar rcs ./libastronomy.a ./astronomy.o
cp ./astronomy/source/c/astronomy.h /usr/include/astronomy.h
cp ./libastronomy.a /usr/lib/libastronomy.a
rm -rf ./astronomy ./astronomy.o ./libastronomy.a

echo "Getting KeeperFX game data..."
echo "---------------------------------------------------------------"
mkdir -p ./AppDir/bin
wget https://github.com/dkfans/keeperfx/releases/download/v1.4.0/keeperfx_1_4_0_complete.7z
bsdtar -xf ./keeperfx_1_4_0_complete.7z -C ./AppDir/bin \
    --exclude '*.exe' --exclude '*.dll' --exclude '*.DLL' --exclude '*.map' \
    --exclude '*.jpg' --exclude '*.sh'
rm -f ./keeperfx_1_4_0_complete.7z
wget https://keeperfx.net/download/alpha/keeperfx-1_4_0_5588-Alpha-patch.7z
bsdtar -xf ./keeperfx-1_4_0_5588-Alpha-patch.7z -C ./AppDir/bin \
    --exclude '*.exe' --exclude '*.dll' --exclude '*.DLL' --exclude '*.map' --exclude '*.sh'
rm -f ./keeperfx-1_4_0_5588-Alpha-patch.7z

echo "Making Nightly build of KeeperFX..."
echo "---------------------------------------------------------------"
REPO="https://github.com/dkfans/keeperfx"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone --recursive "$REPO" ./keeperfx
echo "$VERSION" > ~/version

patch -d ./keeperfx -Np1 -i ../patches/keeperfx-system-deps.patch
cmake -S ./keeperfx -B ./keeperfx-build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build ./keeperfx-build --target keeperfx -j"$(nproc)"
mv -v ./keeperfx-build/keeperfx ./AppDir/bin
awk -F= '/^VER_MAJOR=/{a=$2} /^VER_MINOR=/{b=$2} /^VER_RELEASE=/{c=$2} /^VER_BUILD=/{d=$2} END{print a"."b"."c"."d}' \
    ./keeperfx/version.mk > ./AppDir/bin/keeperfx-version.txt
rm -rf ./keeperfx ./keeperfx-build

echo "Making Nightly build of QTLauncher..."
echo "---------------------------------------------------------------"
git clone --depth 1 https://github.com/dkfans/keeperfx-launcher-qt
patch -d ./keeperfx-launcher-qt -Np1 -i ../patches/launcherfix.patch
cmake -S ./keeperfx-launcher-qt -B ./launcher-build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build ./launcher-build -j"$(nproc)"
mv -v ./launcher-build/keeperfx-launcher-qt ./AppDir/bin
mv -v ./keeperfx-launcher-qt/ext/7z.so ./AppDir/bin
rm -rf ./keeperfx-launcher-qt ./launcher-build
