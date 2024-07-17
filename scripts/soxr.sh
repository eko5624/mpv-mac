#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# High quality, one-dimensional sample-rate conversion library
cd $PACKAGES
git clone https://github.com/chirlu/soxr.git --branch master
cd soxr
# Fixes the build on 64-bit ARM macOS; the __arm__ define used in the
# code isn't defined on 64-bit Apple Silicon.
# Upstream pull request: https://sourceforge.net/p/soxr/code/merge-requests/5/
curl -OL "https://raw.githubusercontent.com/Homebrew/formula-patches/76868b36263be42440501d3692fd3a258f507d82/libsoxr/arm64_defines.patch"
patch -p1 -i arm64_defines.patch || true
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DBUILD_SHARED_LIBS=OFF
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf soxr.tar.xz -C $DIR/opt .