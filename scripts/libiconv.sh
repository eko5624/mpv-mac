#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

myconf=(
    --prefix="$DIR/opt"
    --disable-debug
    --disable-dependency-tracking
    --enable-extra-encodings
    --disable-shared
    --enable-static
    --with-pic
)

if [[ ("$(uname -m)" == "x86_64") && ("$ARCHS" == "arm64") ]]; then
    myconf+=(
        --host=aarch64-apple-darwin
        --target=arm64-apple-macos11.0
    )
fi

if [[ ("$(uname -m)" == "arm64") && ("$ARCHS" == "x86_64") ]]; then
    myconf+=(
        --host=x86_64-apple-darwin
        --target=x86_64-apple-macos11.0
    )
fi

cd $PACKAGES
curl -OL "https://ftpmirror.gnu.org/gnu/libiconv/libiconv-$VER_LIBICONV.tar.gz"
tar -xvf libiconv-$VER_LIBICONV.tar.gz 2>/dev/null >/dev/null
cd libiconv-$VER_LIBICONV
#curl -OL "https://raw.githubusercontent.com/Homebrew/patches/9be2793af/libiconv/patch-utf8mac.diff"
#patch -p1 -i patch-utf8mac.diff
./configure "${myconf[@]}"
make -j $MJOBS
make install

mkdir -p $DIR/opt/lib/pkgconfig
sed -i "" 's|@prefix@|'"${DIR}"'/opt|g' $DIR/iconv.pc
sed -i "" 's|@VERSION@|'"${VER_LIBICONV}"'|g' $DIR/iconv.pc
cp $DIR/iconv.pc $DIR/opt/lib/pkgconfig
cat $DIR/opt/lib/pkgconfig/iconv.pc

cd $DIR
tar -zcvf libiconv.tar.xz -C $DIR/opt .
