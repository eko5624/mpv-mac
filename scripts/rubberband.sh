#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Audio time stretcher tool and library
# depends on: libsamplerate, libsndfile(flac(libogg), lame(ncurses), libogg, libvorbis(libogg), mpg123, opus)
cd $PACKAGES
git clone https://github.com/breakfastquay/rubberband.git
cd rubberband
meson setup build \
  --prefix="$DIR/opt" \
  --buildtype=release \
  --libdir="$DIR/opt/lib" \
  -Ddefault_library=static \
  -Dfft=builtin \
  -Dresampler=libsamplerate \
  -Djni=disabled
meson compile -C build
meson install -C build

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf rubberband.tar.xz -C $DIR/opt .
