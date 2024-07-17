#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Cryptographic & SSL/TLS library
cd $PACKAGES
git clone https://github.com/Mbed-TLS/mbedtls
cd mbedtls
git submodule update --init --recursive
# enable pthread mutexes
sed -i "" 's|//#define MBEDTLS_THREADING_PTHREAD|#define MBEDTLS_THREADING_PTHREAD|g' include/mbedtls/mbedtls_config.h
# allow use of mutexes within mbed TLS
sed -i "" 's|//#define MBEDTLS_THREADING_C|#define MBEDTLS_THREADING_C|g' include/mbedtls/mbedtls_config.h
# enable DTLS-SRTP extension
sed -i "" 's|//#define MBEDTLS_SSL_DTLS_SRTP|#define MBEDTLS_SSL_DTLS_SRTP|g' include/mbedtls/mbedtls_config.h
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_BUILD_TYPE=Release \
  -DPython3_EXECUTABLE="$WORKSPACE/bin/python3" \
  -DENABLE_PROGRAMS=OFF \
  -DUSE_STATIC_MBEDTLS_LIBRARY=ON \
  -DUSE_SHARED_MBEDTLS_LIBRARY=OFF \
  -DINSTALL_MBEDTLS_HEADERS=ON \
  -DENABLE_TESTING=OFF \
  -DGEN_FILES=ON \
  -DMBEDTLS_FATAL_WARNINGS=OFF
cmake --build . -j $MJOBS
cmake --install .

cd $DIR
tar -zcvf mbedtls.tar.xz -C $DIR/opt .
