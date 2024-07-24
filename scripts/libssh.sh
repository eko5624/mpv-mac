#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# C library SSHv1/SSHv2 client and server protocols
# depends on: openssl, zlib
cd $PACKAGES
git clone https://gitlab.com/libssh/libssh-mirror.git
cd libssh-mirror
export OPENSSL_ROOT_DIR="${WORKSPACE}"
export ZLIB_ROOT_DIR="${WORKSPACE}"
mkdir out && cd out
cmake .. \
  -G "Ninja" \
  -DCMAKE_INSTALL_PREFIX="$DIR/opt" \
  -DCMAKE_INSTALL_NAME_DIR="$DIR/opt/lib" \
  -DCMAKE_FIND_ROOT_PATH="$WORKSPACE" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DWITH_SYMBOL_VERSIONING=OFF \
  -DWITH_EXAMPLES=OFF \
  -DWITH_GSSAPI=OFF \
  -DWITH_SERVER=OFF \
  -DWITH_SFTP=ON \
  -DWITH_ZLIB=ON
cmake --build . -j $MJOBS
cmake --install .

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc
echo "Requires.private: libssl libcrypto zlib" >> $DIR/opt/lib/pkgconfig/*.pc
echo "Cflags.private: -DLIBSSH_STATIC" >> $DIR/opt/lib/pkgconfig/*.pc
echo "Libs.private: -lpthread" >> $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libssh.tar.xz -C $DIR/opt .
