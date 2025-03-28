#!/bin/bash
set -e

cd "$(dirname "$0")"
set -a; source tools.env; source ver.sh; set +a

build() {
  echo ""
  echo "building $1"
  echo "======================="
  if [ -f "$TOOLS/$1.done" ]; then
    echo "$1 already built. Remove $TOOLS/$1.done lockfile to rebuild it."
    return 1
  else
    return 0
  fi
}

build_done() {
  echo "" > "$TOOLS/$1.done"
} 

# Modular BSD reimplementation of NASM
#if build "yasm"; then
#  cd $PACKAGES
#  curl $CURL_RETRIES -OL "https://www.tortall.net/projects/yasm/releases/yasm-$VER_YASM.tar.gz"
#  tar -xvf yasm-$VER_YASM.tar.gz 2>/dev/null >/dev/null
#  cd yasm-$VER_YASM
#  ./configure --prefix="${TOOLS}"
#  make -j $MJOBS
#  make install
#  build_done "yasm"
#fi  

# Code snippets in your terminal
if build "nasm"; then
  cd $PACKAGES
  curl $CURL_RETRIES -OL "https://www.nasm.us/pub/nasm/releasebuilds/$VER_NASM/nasm-$VER_NASM.tar.xz"
  tar -xvf nasm-$VER_NASM.tar.xz 2>/dev/null >/dev/null
  cd nasm-$VER_NASM
  ./configure \
    --prefix="${TOOLS}" \
    --disable-shared \
    --enable-static
  make -j $MJOBS
  make install
  build_done "nasm"
fi  

# Macro processing language
if build "m4"; then
  cd $PACKAGES
  curl $CURL_RETRIES -OL "https://ftp.gnu.org/gnu/m4/m4-$VER_M4.tar.gz"
  tar -xvf m4-$VER_M4.tar.gz 2>/dev/null >/dev/null
  cd m4-$VER_M4
  ./configure --prefix="${TOOLS}"
  make -j $MJOBS
  make install
  build_done "m4"
fi  

# Automatic configure script builder
# depends on: m4
if build "autoconf"; then
  cd $PACKAGES
  curl $CURL_RETRIES -OL "https://ftp.gnu.org/gnu/autoconf/autoconf-$VER_AUTOCONF.tar.gz"
  tar -xvf autoconf-$VER_AUTOCONF.tar.gz 2>/dev/null >/dev/null
  cd autoconf-$VER_AUTOCONF
  ./configure --prefix="${TOOLS}"
  make -j $MJOBS
  make install
  build_done "autoconf"
fi  

# Tool for generating GNU Standards-compliant Makefiles
# depends on: autoconf(m4)
if build "automake"; then
  cd $PACKAGES
  curl $CURL_RETRIES -OL "https://ftp.gnu.org/gnu/automake/automake-$VER_AUTOMAKE.tar.gz"
  tar -xvf automake-$VER_AUTOMAKE.tar.gz 2>/dev/null >/dev/null
  cd automake-$VER_AUTOMAKE
  ./configure --prefix="${TOOLS}"
  make -j $MJOBS
  make install
  build_done "automake"
fi  

# Generic library support script
# depends on: m4
if build "libtool"; then
  cd $PACKAGES
  curl $CURL_RETRIES -OL "https://ftpmirror.gnu.org/libtool/libtool-$VER_LIBTOOL.tar.gz"
  tar -xvf libtool-$VER_LIBTOOL.tar.gz 2>/dev/null >/dev/null
  cd libtool-$VER_LIBTOOL
  ./configure \
    --prefix="${TOOLS}" \
    --enable-static \
    --disable-shared
  make -j $MJOBS
  make install
  build_done "libtool"
fi  

# Package compiler and linker metadata toolkit
# depends on: autoconf(m4), automake(autoconf(m4)), libtool(m4)
if build "pkgconf"; then
  cd $PACKAGES
  git clone https://github.com/pkgconf/pkgconf.git --branch pkgconf-$VER_PKGCONF
  cd pkgconf
  LIBTOOLIZE="libtoolize"
  ./autogen.sh
  ./configure \
    --prefix="${TOOLS}" \
    --with-pkg-config-dir="${TOOLS}/lib/pkgconfig":"${TOOLS}/share/pkgconfig"
  make -j $MJOBS
  make install
  cd $TOOLS/bin
  ln -s pkgconf pkg-config
  build_done "pkgconf"
fi

# zlib: General-purpose lossless data-compression library
if build "zlib"; then
  cd $PACKAGES
  curl -OL "https://github.com/madler/zlib/releases/download/v$VER_ZLIB/zlib-$VER_ZLIB.tar.xz"
  tar -xvf zlib-$VER_ZLIB.tar.xz 2>/dev/null >/dev/null
  cd zlib-$VER_ZLIB
  ./configure \
    --prefix="${TOOLS}" \
    --static
  make -j $MJOBS
  make install
  build_done "zlib"
fi 

# Cryptography and SSL/TLS Toolkit
# depends on: zlib
if build "openssl"; then
  cd $PACKAGES
  curl -OL "https://www.openssl.org/source/openssl-"${VER_OPENSSL_3}".tar.gz"
  tar -xvf openssl-"${VER_OPENSSL_3}".tar.gz 2>/dev/null >/dev/null
  cd openssl-"${VER_OPENSSL_3}"
  ./config \
    --prefix="${TOOLS}" \
    --openssldir="${TOOLS}" \
    --with-zlib-include="$TOOLS/include" \
    --with-zlib-lib="$TOOLS/lib" \
    no-shared \
    zlib
  make -j $MJOBS
  make install
  build_done "openssl"
fi

# Portable Foreign Function Interface library
#if build "libffi"; then
#  cd $PACKAGES
#  git clone https://github.com/libffi/libffi.git
#  cd libffi
#  ./autogen.sh
#  ./config --prefix="${TOOLS}"
#  make -j $MJOBS
#  make install
#  build_done "libffi"
#fi

# Interpreted, interactive, object-oriented programming language
# depends on: openssl(zlib), zlib
if build "python"; then
  cd $PACKAGES
  git clone https://github.com/python/cpython --branch 3.13
  cd cpython
  ./configure \
    --prefix="${TOOLS}"
  make -j $MJOBS
  make install
  cd "${TOOLS}"/bin
  ln -s python3.13 python
  build_done "python"

  #pip3 meson ninja jsonschema Jinja2
  if ! [[ -x $(command -v "pip3") ]]; then
    python3 -m ensurepip --upgrade
  fi

  pip3 install pip setuptools --quiet --upgrade --no-cache-dir --disable-pip-version-check
  for r in meson ninja jsonschema Jinja2 pytest; do
      pip3 install ${r} --quiet --upgrade --no-cache-dir --disable-pip-version-check
  done
fi

# Text-based UI library
#if build "ncurses"; then
#  cd $PACKAGES
#  curl -OL "https://ftpmirror.gnu.org/ncurses/ncurses-$VER_NCURSES.tar.gz"
#  tar -xvf ncurses-$VER_NCURSES.tar.gz 2>/dev/null >/dev/null
#  cd ncurses-$VER_NCURSES
#  ./configure --prefix="${TOOLS}"
#  make -j $MJOBS
#  make install
#  build_done "ncurses"
#fi  

#if build "cmake"; then
#  cd $PACKAGES
#  curl $CURL_RETRIES -OL "https://github.com/Kitware/CMake/releases/download/v$VER_CMAKE/cmake-$VER_CMAKE.tar.gz"
#  tar -xvf cmake-$VER_CMAKE.tar.gz 2>/dev/null >/dev/null
#  CXXFLAGS_BACKUP=$CXXFLAGS
#  export CXXFLAGS+=" -std=c++11"
#  cd cmake-$VER_CMAKE
#  ./configure \
#    --prefix="${TOOLS}" \
#    --parallel="${MJOBS}" \
#    -- \
#    -DCMAKE_USE_OPENSSL=OFF
#  make -j $MJOBS
#  make install
#  build_done "cmake"
#  export CXXFLAGS=$CXXFLAGS_BACKUP
#fi  

# Conversion library
if build "libiconv"; then
  cd $PACKAGES
  curl -OL "https://ftp.gnu.org/gnu/libiconv/libiconv-$VER_LIBICONV.tar.gz"
  tar -xvf libiconv-$VER_LIBICONV.tar.gz 2>/dev/null >/dev/null
  cd libiconv-$VER_LIBICONV
  #curl -OL "https://raw.githubusercontent.com/Homebrew/patches/9be2793af/libiconv/patch-utf8mac.diff"
  #patch -p1 -i patch-utf8mac.diff
  ./configure \
    --prefix="${TOOLS}" \
    --disable-debug \
    --disable-dependency-tracking \
    --enable-extra-encodings \
    --disable-shared \
    --enable-static \
    --with-pic
  make -j $MJOBS
  make install
  cp $DIR/iconv.pc ${TOOLS}/lib/pkgconfig
  sed -i "" 's|@prefix@|'"${TOOLS}"'|g' ${TOOLS}/lib/pkgconfig/iconv.pc
  sed -i "" 's|@VERSION@|'"${VER_LIBICONV}"'|g' ${TOOLS}/lib/pkgconfig/iconv.pc
  build_done "libiconv"
fi

# libxml2: GNOME XML library
# depends on: libiconv, zlib
if build "libxml2"; then
  cd $PACKAGES
  git clone https://github.com/GNOME/libxml2.git --branch master --depth 1
  cd libxml2
  autoreconf -fvi
  ./configure \
    --prefix="${TOOLS}" \
    --without-python \
    --without-lzma \
    --with-iconv="${TOOLS}" \
    --disable-shared \
    --enable-static
  make -j $MJOBS
  make install
  build_done "libxml2"
fi

# gettext: GNU internationalization (i18n) and localization (l10n) library
# depends on: libxml2(zlib), ncurses
if build "gettext"; then
  cd $PACKAGES
  curl -OL "https://ftp.gnu.org/gnu/gettext/gettext-$VER_GETTEXT.tar.gz"
  tar -xvf gettext-$VER_GETTEXT.tar.gz 2>/dev/null >/dev/null
  cd gettext-$VER_GETTEXT
  ./configure \
    --prefix="${TOOLS}" \
    --enable-static \
    --disable-shared \
    --disable-silent-rules \
    --with-libiconv-prefix="${TOOLS}" \
    --with-included-gettext \
    --with-included-glib \
    --with-included-libcroco \
    --with-included-libunistring \
    --with-included-libxml \
    --disable-java \
    --disable-csharp \
    --without-git \
    --without-cvs \
    --without-xz
  make -j $MJOBS
  make install
  cp $DIR/intl.pc ${TOOLS}/lib/pkgconfig
  sed -i "" 's|@prefix@|'"${TOOLS}"'|g' ${TOOLS}/lib/pkgconfig/intl.pc
  sed -i "" 's|@VERSION@|'"${VER_GETTEXT}"'|g' ${TOOLS}/lib/pkgconfig/intl.pc
  build_done "gettext"
fi
