#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

cd $PACKAGES
git clone https://github.com/mpv-player/mpv.git

LDFLAGS+=" -Wl,-no_compact_unwind"
cd mpv
# workaround slow opening video with vo=libmpv(https://github.com/mpv-player/mpv/issues/14465)
curl -OL https://patch-diff.githubusercontent.com/raw/eko5624/mpv/pull/2.patch
patch -p1 -i 2.patch
#export TOOLCHAINS=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" /Library/Developer/Toolchains/swift-latest.xctoolchain/Info.plist)
meson setup build \
  --buildtype=release \
  -Dwrap_mode=nodownload \
  -Db_lto=true \
  -Db_lto_mode=thin \
  -Dlibmpv=true \
  -Diconv=enabled \
  -Dmanpage-build=disabled \
  -Dswift-flags="${SWIFT_FLAGS}"
meson compile -C build
#meson compile -C build macos-bundle

# get latest commit sha
short_sha=$(git rev-parse --short HEAD)
echo $short_sha > build/SHORT_SHA

#bundle mpv
cp -r TOOLS/osxbundle/mpv.app build
cp build/mpv build/mpv.app/Contents/MacOS
cp $WORKSPACE/lib/libluajit-5.1.2.dylib build/mpv.app/Contents/MacOS/lib
cp $WORKSPACE/lib/libvapoursynth-script.0.dylib build/mpv.app/Contents/MacOS/lib
mkdir -p build/mpv.app/Contents/Frameworks
mkdir -p build/mpv.app/Contents/Resources/vulkan/icd.d
cp $WORKSPACE/lib/libMoltenVK.dylib build/mpv.app/Contents/Frameworks
cp $WORKSPACE/share/vulkan/icd.d/MoltenVK_icd.json build/mpv.app/Contents/Resources/vulkan/icd.d
sed -i "" 's|../../../lib/libMoltenVK.dylib|../../../Frameworks/libMoltenVK.dylib|g' build/mpv.app/Contents/Resources/vulkan/icd.d/MoltenVK_icd.json

for f in build/mpv.app/Contents/MacOS/lib/*.dylib; do
  sudo install_name_tool -id "@executable_path/lib/$(basename $f)" "$f"
  sudo install_name_tool -change "$DIR/opt/lib/$(basename $f)" "@executable_path/lib/$(basename $f)" build/mpv.app/Contents/MacOS/mpv
done

# Codesign mpv.app
codesign --deep -fs - build/mpv.app

cd $DIR
# Zip mpv.app and mpv config files
mkdir mpv
git clone https://github.com/eko5624/mpv-config.git
mv mpv-config/macos_config mpv
cp -r $PACKAGES/mpv/build/mpv.app mpv
cp $PACKAGES/mpv/build/SHORT_SHA mpv
zip -r mpv-$ARCHS-git-$short_sha.zip mpv/*

# Zip libmpv
mkdir -p libmpv/include
cp $PACKAGES/mpv/build/libmpv.2.dylib libmpv
cp $PACKAGES/mpv/build/mpv.app/Contents/MacOS/lib/*.dylib libmpv
cp $PACKAGES/mpv/libmpv/client.h libmpv/include
cp $PACKAGES/mpv/libmpv/stream_cb.h libmpv/include
cp $PACKAGES/mpv/libmpv/render.h libmpv/include
cp $PACKAGES/mpv/libmpv/render_gl.h libmpv/include
zip -r libmpv-$ARCHS-$short_sha.zip libmpv/*

# Zip ffmpeg
mkdir ffmpeg
cp $WORKSPACE/bin/ffmpeg ffmpeg
mv $WORKSPACE/SHORT_SHA ffmpeg
ffmpeg_sha=$(cat $WORKSPACE/SHORT_SHA)
zip -r ffmpeg-$ARCHS-$ffmpeg_sha.zip ffmpeg/*
