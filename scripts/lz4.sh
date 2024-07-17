#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# General-purpose lossless data-compression library
cd $PACKAGES
git clone https://github.com/lz4/lz4.git --branch dev
cd lz4
make install PREFIX="$DIR/opt"

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf lz4.tar.xz -C $DIR/opt .