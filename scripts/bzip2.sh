#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Freely available high-quality data compressor
cd $PACKAGES
git clone https://gitlab.com/bzip2/bzip2.git
cd bzip2
meson setup work \
  --prefix="$DIR/opt" \
  --buildtype=release \
  --libdir="$DIR/opt/lib" \
  --default-library=static
meson compile -C work
meson install -C work

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf bzip2.tar.xz -C $DIR/opt .