#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --openssldir="$DIR/opt"
    --with-zlib-include="$WORKSPACE/include"
    --with-zlib-lib="$WORKSPACE/lib"
    no-shared
    zlib
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        darwin64-arm64-cc
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        darwin64-x86_64-cc
    )
fi

# Cryptography and SSL/TLS Toolkit
# depends on: zlib
cd $PACKAGES
curl -OL "https://www.openssl.org/source/openssl-"${VER_OPENSSL_3}".tar.gz"
tar -xvf openssl-"${VER_OPENSSL_3}".tar.gz 2>/dev/null >/dev/null
cd openssl-"${VER_OPENSSL_3}"
./Configure "${myconf[@]}"
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf openssl.tar.xz -C $DIR/opt .
