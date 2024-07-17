#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Library from the Modplug-XMMS project
cd $PACKAGES
git clone https://github.com/Konstanty/libmodplug.git
cd libmodplug
# Fix -flat_namespace being used on Big Sur and later.
#curl -OL "https://raw.githubusercontent.com/Homebrew/formula-patches/03cf8088210822aa2c1ab544ed58ea04c897d9c4/libtool/configure-big_sur.diff"
#execute patch -p1 -i configure-big_sur.diff || true
autoreconf -fvi
./configure \
  --prefix="$DIR/opt" \
  --disable-debug \
  --disable-dependency-tracking \
  --disable-silent-rules \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libmodplug.tar.xz -C $DIR/opt .