#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

builddir="Package/Latest/MoltenVK/dynamic/dylib/macOS"
xcodebuild="xcodebuild ARCHS=$ARCHS ONLY_ACTIVE_ARCH=YES"
# Implementation of the Vulkan graphics and compute API on top of Metal
cd $PACKAGES
git clone https://github.com/KhronosGroup/MoltenVK.git --branch main
cd MoltenVK
sed -i '' 's/xcodebuild "$@"/'"${xcodebuild}"' "$@"/g' fetchDependencies
sed -i '' 's/XCODEBUILD := .*/XCODEBUILD := '"${xcodebuild}"'/' Makefile
./fetchDependencies --macos
make macos
sed -i '' "s|./libMoltenVK|../../../Frameworks/libMoltenVK|g" Package/Latest/MoltenVK/dynamic/dylib/macOS/MoltenVK_icd.json
mkdir -p "$DIR/opt/lib"
mkdir -p "$DIR/opt/share/vulkan/icd.d"
install -vm755 Package/Latest/MoltenVK/dynamic/dylib/macOS/libMoltenVK.dylib "$DIR/opt/lib"
install -vm644 Package/Latest/MoltenVK/dynamic/dylib/macOS/MoltenVK_icd.json "$DIR/opt/share/vulkan/icd.d"

# Force 11 deployment target for all homebrew formulas
#find $(brew --repository)/Library/Taps -type f -iname *rb -exec sed -i "" $'s/def install/def install\\\n    ENV["MACOSX_DEPLOYMENT_TARGET"] = "11"\\\n/' {} \;          
#brew install molten-vk

cd $DIR
#tar -zcvf molten-vk.tar.xz -C `brew --prefix molten-vk` .
tar -zcvf molten-vk.tar.xz -C $DIR/opt .
