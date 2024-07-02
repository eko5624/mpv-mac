#!/bin/bash
set -e

cd "$(dirname "$0")"
set -a; source build.env; source ver.sh; set +a

#pkg-config
cd $PACKAGES
curl $CURL_RETRIES -OL "https://pkgconfig.freedesktop.org/releases/pkg-config-${VER_PKG_CONFIG}.tar.gz"
tar -xvf pkg-config-${VER_PKG_CONFIG}.tar.gz
cd pkg-config-${VER_PKG_CONFIG}
./configure \
  --silent --prefix="${WORKSPACE}" \
  --with-pc-path="${WORKSPACE}"/lib/pkgconfig \
  --with-internal-glib
make -j $MJOBS
make install

#yasm
cd $PACKAGES
curl $CURL_RETRIES -OL "https://www.tortall.net/projects/yasm/releases/yasm-$VER_YASM.tar.gz"
tar -xvf yasm-$VER_YASM.tar.gz
cd yasm-$VER_YASM
./configure --prefix="${WORKSPACE}"
make -j $MJOBS
make install

#nasm
cd $PACKAGES
curl $CURL_RETRIES -OL "https://www.nasm.us/pub/nasm/releasebuilds/$VER_NASM/nasm-$VER_NASM.tar.xz"
tar -xvf nasm-$VER_NASM.tar.xz
cd nasm-$VER_NASM
./configure --prefix="${WORKSPACE}"
make -j $MJOBS
make install

#m4
cd $PACKAGES
curl $CURL_RETRIES -OL "https://ftp.gnu.org/gnu/m4/m4-$VER_M4.tar.gz"
tar -xvf m4-$VER_M4.tar.gz
cd m4-$VER_M4
./configure --prefix="${WORKSPACE}"
make -j $MJOBS
make install

#autoconf
cd $PACKAGES
curl $CURL_RETRIES -OL "https://ftp.gnu.org/gnu/autoconf/autoconf-$VER_AUTOCONF.tar.gz"
tar -xvf autoconf-$VER_AUTOCONF.tar.gz
cd autoconf-$VER_AUTOCONF
./configure --prefix="${WORKSPACE}"
make -j $MJOBS
make install

#automake
cd $PACKAGES
curl $CURL_RETRIES -OL "https://ftp.gnu.org/gnu/automake/automake-$VER_AUTOMAKE.tar.gz"
tar -xvf automake-$VER_AUTOMAKE.tar.gz
cd automake-$VER_AUTOMAKE
./configure --prefix="${WORKSPACE}"
make -j $MJOBS
make install

#libtool
cd $PACKAGES
curl $CURL_RETRIES -OL "https://ftpmirror.gnu.org/libtool/libtool-$VER_LIBTOOL.tar.gz"
tar -xvf libtool-$VER_LIBTOOL.tar.gz
cd libtool-$VER_LIBTOOL
./configure --prefix="${WORKSPACE}"
make -j $MJOBS
make install

#python
cd $PACKAGES
git clone https://github.com/python/cpython --branch 3.12
cd cpython
./configure \
  --prefix="${WORKSPACE}"
make -j $MJOBS
make install
cd "${WORKSPACE}"/bin
ln -s python3.12 python

#pip3 meson ninja jsonschema Jinja2
if [[ -x $(command -v "pip3") ]]; then
  pip3 install pip setuptools --quiet --upgrade --no-cache-dir --disable-pip-version-check
  for r in meson ninja jsonschema Jinja2; do
      pip3 install ${r} --quiet --upgrade --no-cache-dir --disable-pip-version-check
  done
fi

#cmake
cd $PACKAGES
curl $CURL_RETRIES -OL "https://github.com/Kitware/CMake/releases/download/v$VER_CMAKE/cmake-$VER_CMAKE.tar.gz"
cd cmake-$VER_CMAKE
./configure \
  --prefix="${WORKSPACE}" \
  --parallel="${MJOBS}" \
  -- \
  -DCMake_BUILD_LTO=ON
make -j $MJOBS
make install

