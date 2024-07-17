#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Library and utilities for processing GIFs
cd $PACKAGES
curl -OL "https://netcologne.dl.sourceforge.net/project/giflib/giflib-$VER_GIFLIB.tar.gz"
tar -xvf giflib-$VER_GIFLIB.tar.gz 2>/dev/null >/dev/null
cd giflib-$VER_GIFLIB
make all
make PREFIX="$DIR/opt" install

cd $DIR
tar -zcvf giflib.tar.xz -C $DIR/opt .