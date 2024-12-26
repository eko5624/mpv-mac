#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --disable-assembly
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        --host=aarch64-apple-darwin
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        --host=x86_64-apple-darwin
    )
fi

# High-performance, high-quality MPEG-4 video library
cd $PACKAGES
curl -OL "https://downloads.xvid.com/downloads/xvidcore-$VER_XVID.tar.gz"
tar -xvf xvidcore-$VER_XVID.tar.gz 2>/dev/null >/dev/null
cd xvidcore/build/generic
./configure "${myconf[@]}"
make -j $MJOBS
make install

#cp ../../src/xvid.h $DIR/opt/include
#mv $DIR/opt/lib/xvidcore.a $DIR/opt/lib/libxvidcore.a

cd $DIR
tar -zcvf xvid.tar.xz -C $DIR/opt .
