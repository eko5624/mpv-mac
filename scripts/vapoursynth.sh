#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Video processing framework with simplicity in mind
pip install -U cython
cd $PACKAGES
git clone https://github.com/vapoursynth/vapoursynth.git --branch R$VER_VAPOURSYNTH
cd vapoursynth
./autogen.sh
./configure \
	--prefix="$DIR/opt" \
  --disable-silent-rules \
  --disable-dependency-tracking \
  --with-cython="$WORKSPACE/bin/cython" \
  --with-plugindir="$DIR/opt/lib/vapoursynth" \
  --with-python_prefix="$DIR/opt" \
  --with-python_exec_prefix="$DIR/opt"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf vapoursynth.tar.xz -C $DIR/opt .