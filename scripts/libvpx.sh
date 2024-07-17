#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# VP8/VP9 video codec
cd $PACKAGES
git clone https://chromium.googlesource.com/webm/libvpx.git
cd libvpx
echo "Applying Darwin patch"
sed "s/,--version-script//g" build/make/Makefile >build/make/Makefile.patched
sed "s/-Wl,--no-undefined -Wl,-soname/-Wl,-undefined,error -Wl,-install_name/g" build/make/Makefile.patched >build/make/Makefile
cd build
../configure \
  --prefix="$DIR/opt" \
  --disable-dependency-tracking \
  --disable-examples \
  --disable-unit-tests \
  --disable-shared \
  --enable-static \
  --enable-pic \
  --enable-vp9-highbitdepth \
  --enable-runtime-cpu-detect \
  --as=yasm
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libvpx.tar.xz -C $DIR/opt .