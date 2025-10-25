#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --buildtype=release
    -Dwrap_mode=nodownload
    -Dlibmpv=true
    -Diconv=enabled
    -Dmanpage-build=disabled
    -Dswift-flags="-target $ARCHS-apple-macosx11.0"
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        --cross-file=$DIR/meson_arm64.txt
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        --cross-file=$DIR/meson_x86_64.txt
    )
fi

LDFLAGS+=" -Wl,-no_compact_unwind"
cd $PACKAGES
git clone https://github.com/mpv-player/mpv.git
cd mpv
#汉化select.lua菜单项
#sed -i "" 's|"Subtitles",|"字幕轨",|g' player/lua/select.lua
#sed -i "" 's|"Secondary subtitles",|"次字幕",|g' player/lua/select.lua
#sed -i "" 's|"Subtitle lines",|"字幕内容",|g' player/lua/select.lua
#sed -i "" 's|"Audio tracks",|"音频轨",|g' player/lua/select.lua
#sed -i "" 's|"Video tracks",|"视频轨",|g' player/lua/select.lua
#sed -i "" 's|"Playlist",|"播放列表",|g' player/lua/select.lua
#sed -i "" 's|"Chapters",|"章节",|g' player/lua/select.lua
#sed -i "" 's|"Audio devices",|"音频设备",|g' player/lua/select.lua
#sed -i "" 's|"Key bindings",|"快捷键",|g' player/lua/select.lua
#sed -i "" 's|"History",|"播放历史",|g' player/lua/select.lua
#sed -i "" 's|"Watch later",|"稍后播放",|g' player/lua/select.lua
#sed -i "" 's|"Stats for nerds",|"统计信息",|g' player/lua/select.lua
#sed -i "" 's|"File info",|"文件信息",|g' player/lua/select.lua
#sed -i "" 's|"Help",|"帮助",|g' player/lua/select.lua
#git reset --hard 90a78925452c80f43837210f13b8cd39c4075719
#export TOOLCHAINS=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" /Library/Developer/Toolchains/swift-latest.xctoolchain/Info.plist)
if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]] || [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    ln -s $WORKSPACE/include/libplacebo libplacebo
    ln -s $WORKSPACE/include/libavutil libavutil
    ln -s $WORKSPACE/include/vulkan vulkan
    ln -s $WORKSPACE/include/vk_video vk_video
fi    
meson setup build "${myconf[@]}"
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
cp $WORKSPACE/etc/vulkan/icd.d/MoltenVK_icd.json build/mpv.app/Contents/Resources/vulkan/icd.d
sed -i "" 's|/Users/runner/work/mpv-mac/mpv-mac/opt/lib/libMoltenVK.dylib|../../../Frameworks/libMoltenVK.dylib|g' build/mpv.app/Contents/Resources/vulkan/icd.d/MoltenVK_icd.json

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
cp $PACKAGES/mpv/include/mpv/client.h libmpv/include
cp $PACKAGES/mpv/include/mpv/stream_cb.h libmpv/include
cp $PACKAGES/mpv/include/mpv/render.h libmpv/include
cp $PACKAGES/mpv/include/mpv/render_gl.h libmpv/include
zip -r libmpv-$ARCHS-$short_sha.zip libmpv/*

# Zip ffmpeg
mkdir ffmpeg
cp $WORKSPACE/bin/ffmpeg ffmpeg
cp $WORKSPACE/bin/ffprobe ffmpeg
cp $WORKSPACE/bin/ffplay ffmpeg
mv $WORKSPACE/SHORT_SHA ffmpeg
ffmpeg_sha=$(cat ffmpeg/SHORT_SHA)
zip -r ffmpeg-$ARCHS-$ffmpeg_sha.zip ffmpeg/*
