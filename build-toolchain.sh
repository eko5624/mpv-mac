#!/bin/bash
set -e

cd "$(dirname "$0")"
set -a; source build.env; source ver.sh; set +a

build() {
  echo ""
  echo "building $1"
  echo "======================="
  if [ -f "$WORKSPACE/$1.done" ]; then
    echo "$1 already built. Remove $WORKSPACE/$1.done lockfile to rebuild it."
    return 1
  else
    return 0
  fi
}

build_done() {
  echo "" > "$WORKSPACE/$1.done"
}

# Manage compile and link flags for libraries
if build "pkg-config"; then
  cd $PACKAGES
  curl $CURL_RETRIES -OL "https://pkgconfig.freedesktop.org/releases/pkg-config-${VER_PKG_CONFIG}.tar.gz"
  tar -xvf pkg-config-${VER_PKG_CONFIG}.tar.gz 2>/dev/null >/dev/null
  cd pkg-config-${VER_PKG_CONFIG}
  ./configure \
    --silent --prefix="${WORKSPACE}" \
    --with-pc-path="${WORKSPACE}"/lib/pkgconfig \
    --with-internal-glib
  make -j $MJOBS
  make install
  build_done "pkg-config"
fi  

# Modular BSD reimplementation of NASM
if build "yasm"; then
  cd $PACKAGES
  curl $CURL_RETRIES -OL "https://www.tortall.net/projects/yasm/releases/yasm-$VER_YASM.tar.gz"
  tar -xvf yasm-$VER_YASM.tar.gz 2>/dev/null >/dev/null
  cd yasm-$VER_YASM
  ./configure --prefix="${WORKSPACE}"
  make -j $MJOBS
  make install
  build_done "yasm"
fi  

# Code snippets in your terminal
if build "nasm"; then
  cd $PACKAGES
  curl $CURL_RETRIES -OL "https://www.nasm.us/pub/nasm/releasebuilds/$VER_NASM/nasm-$VER_NASM.tar.xz"
  tar -xvf nasm-$VER_NASM.tar.xz 2>/dev/null >/dev/null
  cd nasm-$VER_NASM
  ./configure \
    --prefix="${WORKSPACE}" \
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
  ./configure --prefix="${WORKSPACE}"
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
  ./configure --prefix="${WORKSPACE}"
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
  ./configure --prefix="${WORKSPACE}"
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
    --prefix="${WORKSPACE}" \
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
    --prefix="${WORKSPACE}" \
    --with-pkg-config-dir="${WORKSPACE}/lib/pkgconfig":"${WORKSPACE}/share/pkgconfig"
  make -j $MJOBS
  make install
  build_done "pkgconf"
fi

# Text-based UI library
#if build "ncurses"; then
#  cd $PACKAGES
#  curl -OL "https://ftpmirror.gnu.org/ncurses/ncurses-$VER_NCURSES.tar.gz"
#  tar -xvf ncurses-$VER_NCURSES.tar.gz 2>/dev/null >/dev/null
#  cd ncurses-$VER_NCURSES
#  ./configure --prefix="${WORKSPACE}"
#  make -j $MJOBS
#  make install
#  build_done "ncurses"
#fi
