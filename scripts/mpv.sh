#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

cd $PACKAGES
git clone https://github.com/mpv-player/mpv.git
git reset --hard 23843b4aa594dc8c885575f3d237cde3c29398a2

LDFLAGS+=" -Wl,-no_compact_unwind"
cd mpv
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

# bundle mpv
cp -r TOOLS/osxbundle/mpv.app build
cp build/mpv build/mpv.app/Contents/MacOS
cp $WORKSPACE/lib/libluajit-5.1.2.dylib build/mpv.app/Contents/MacOS/lib
#cp $WORKSPACE/lib/libvapoursynth-script.0.dylib build/mpv.app/Contents/MacOS/lib
mkdir -p build/mpv.app/Contents/Frameworks
mkdir -p build/mpv.app/Contents/Resources/vulkan/icd.d
cp $WORKSPACE/lib/libMoltenVK.dylib build/mpv.app/Contents/Frameworks
cp $WORKSPACE/share/vulkan/icd.d/MoltenVK_icd.json build/mpv.app/Contents/Resources/vulkan/icd.d
sed -i "" 's|../../../lib/libMoltenVK.dylib|../../../Frameworks/libMoltenVK.dylib|g' build/mpv.app/Contents/Resources/vulkan/icd.d/MoltenVK_icd.json

mpv_deps=($(otool -L $PACKAGES/mpv/build/mpv.app/Contents/MacOS/mpv | grep -e '\t' | grep -Ev "\/usr\/lib|\/System|@rpath" | awk '{ print $1 }'))
for f in "${mpv_deps[@]}"; do
  sudo install_name_tool -id "@executable_path/lib/$(basename $f)" "build/mpv.app/Contents/MacOS/lib/$(basename $f)"
  sudo install_name_tool -change "$f" "@executable_path/lib/$(basename $f)" build/mpv.app/Contents/MacOS/mpv
done

# setting rpath
rpaths=($(otool -l build/mpv.app/Contents/MacOS/mpv | grep -A2 LC_RPATH | grep path | awk '{ print $2 }'))
for f in "${rpaths[@]}"; do
  sudo install_name_tool -delete_rpath $f build/mpv.app/Contents/MacOS/mpv
done
sudo install_name_tool -add_rpath @executable_path/lib build/mpv.app/Contents/MacOS/mpv


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
ffmpeg_sha=$(cat ffmpeg/SHORT_SHA)
zip -r ffmpeg-$ARCHS-$ffmpeg_sha.zip ffmpeg/*
