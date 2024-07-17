#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Implementation of the Vulkan graphics and compute API on top of Metal
#cd $PACKAGES
#git clone https://github.com/KhronosGroup/MoltenVK.git --branch main
#cd MoltenVK
#./fetchDependencies --macos
#make macos
#sed -i '' "s|./libMoltenVK|$WORKSPACE/lib/libMoltenVK|g" Package/Latest/MoltenVK/dynamic/dylib/macOS/MoltenVK_icd.json
#mkdir -p "$DIR/opt/share/vulkan/icd.d"
#install -vm755 Package/Latest/MoltenVK/dynamic/dylib/macOS/libMoltenVK.dylib "$DIR/opt/lib"
#install -vm644 Package/Latest/MoltenVK/dynamic/dylib/macOS/MoltenVK_icd.json "$DIR/opt/share/vulkan/icd.d"

brew install molten-vk
cd $DIR
tar -zcvf molten-vk.tar.xz -C `brew --prefix molten-vk` .