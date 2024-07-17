#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Cryptography and SSL/TLS Toolkit
cd $PACKAGES
curl -OL "https://www.openssl.org/source/openssl-"${VER_OPENSSL_3}".tar.gz"
tar -xvf openssl-"${VER_OPENSSL_3}".tar.gz 2>/dev/null >/dev/null
cd openssl-"${VER_OPENSSL_3}"
./config \
  --prefix="$DIR/opt" \
  --openssldir="$DIR/opt" \
  --with-zlib-include="$WORKSPACE/include" \
  --with-zlib-lib="$WORKSPACE/lib" \
  no-shared \
  zlib
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf openssl.tar.xz -C $DIR/opt .