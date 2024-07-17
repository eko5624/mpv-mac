#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# depends on: zlib
# GNOME XML library
cd $PACKAGES
git clone https://github.com/GNOME/libxml2.git
cd libxml2
# Fix crash when using Python 3 using Fedora's patch.
# Reported upstream:
# https://bugzilla.gnome.org/show_bug.cgi?id=789714
# https://gitlab.gnome.org/GNOME/libxml2/issues/12
#execute curl $CURL_RETRIES -L --silent -o fix_crash.patch "https://bugzilla.opensuse.org/attachment.cgi?id=746044"
#execute patch -p1 -i fix_crash.patch
autoreconf -fvi
./configure \
  --prefix="$DIR/opt" \
  --disable-shared \
  --enable-static \
  --without-python \
  --without-lzma
make -j $MJOBS
make install

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libxml2.tar.xz -C $DIR/opt .
