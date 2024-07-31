#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Video processing framework with simplicity in mind
# depends on: zimg
pip install -U cython wheel
cd $PACKAGES
git clone https://github.com/vapoursynth/vapoursynth.git --branch R$VER_VAPOURSYNTH
cd vapoursynth
./autogen.sh
sed -i "" 's|pkglibdir = $(libdir)|pkglibdir = $(exec_prefix)|g' Makefile.in
./configure \
  --prefix="$DIR/opt" \
  --disable-silent-rules \
  --disable-dependency-tracking \
  --with-cython=$pythonLocation/bin/cython \
  --with-plugindir=/usr/local/lib/vapoursynth \
  --with-python_prefix=/usr/local/Cellar/vapoursynth/$VER_VAPOURSYNTH \
  --with-python_exec_prefix=/usr/local/Cellar/vapoursynth/$VER_VAPOURSYNTH
make -j $MJOBS
make install
sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf vapoursynth.tar.xz -C $DIR/opt .

# Force 11 deployment target for all homebrew formulas
#find $(brew --repository)/Library/Taps -type f -iname *rb -exec sed -i "" $'s/def install/def install\\\n    ENV["MACOSX_DEPLOYMENT_TARGET"] = "11"\\\n/' {} \;          
#brew install vapoursynth
#rm `brew --prefix vapoursynth`/lib/pkgconfig/*.pc
#cp vapoursynth*.pc `brew --prefix vapoursynth`/lib/pkgconfig

#cd $DIR
#tar -zcvf vapoursynth.tar.xz -C `brew --prefix vapoursynth` .