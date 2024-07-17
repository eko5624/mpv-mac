#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Embeddable Javascript interpreter
cd $PACKAGES
git clone https://github.com/ccxvii/mujs.git --branch "$VER_MUJS"
cd mujs
curl -OL https://raw.githubusercontent.com/shinchiro/mpv-winbuild-cmake/master/packages/mujs-0001-add-exe-to-binary-name.patch
patch -p1 -i mujs-0001-add-exe-to-binary-name.patch
#revert to 1.3.2 for finding libmujs.a
#git reset --hard 0e611cdc0c81a90dabfcb2ab96992acca95b886d
#curl -OL https://raw.githubusercontent.com/eko5624/mpv-macos-intel/macOS-10.13/mujs-finding-libmujs.diff
#xecute patch -p1 -i mujs-finding-libmujs.diff
make prefix="$DIR/opt" release
make prefix="$DIR/opt" install

#workaround Could not resolve library: build/release/libmujs.dylib
#sudo install_name_tool -id "$DIR/opt/lib/libmujs.dylib" "$DIR/opt/lib/libmujs.dylib"

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf mujs.tar.xz -C $DIR/opt .