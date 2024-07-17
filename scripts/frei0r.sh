#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Minimalistic plugin API for video effects
cd $PACKAGES
git clone https://github.com/dyne/frei0r.git
cd frei0r
# Disable opportunistic linking against Cairo
sed -i "" '/find_package (Cairo)/d' CMakeLists.txt
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DBUILD_SHARED_LIBS=OFF \
  -DWITHOUT_OPENCV=ON \
  -DWITHOUT_GAVL=ON
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf frei0r.tar.xz -C $DIR/opt .