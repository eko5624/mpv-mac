#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: libogg
# Vorbis General Audio Compression Codec
cd $PACKAGES
git clone https://github.com/AO-Yumi/vorbis_aotuv.git
cd vorbis_aotuv
chmod +x ./autogen.sh
./autogen.sh
sed -i "" 's/ -force_cpusubtype_ALL//g' configure
./configure \
  --prefix="$DIR/opt" \
  --with-ogg-libraries="${WORKSPACE}"/lib \
  --with-ogg-includes="${WORKSPACE}"/include/ \
  --disable-oggtest \
  --disable-shared \
  --enable-static
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libvorbis.tar.xz -C $DIR/opt .