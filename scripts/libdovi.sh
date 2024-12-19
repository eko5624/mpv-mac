#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Library to read and write Dolby Vision metadata (C-API)
if [ "$ARCHS" == "x86_64" ]; then
  rustup target add x86_64-apple-darwin
  cargo install cargo-c
elif [ "$ARCHS" == "arm64" ]; then
  #rustup target add x86_64-apple-darwin
  curl -OL https://github.com/eko5624/mpv-mac/releases/download/tools/cargo-c-macos-x86_64.zip
  7z x cargo-c-macos-x86_64.zip
  rustup target add aarch64-apple-darwin
  #rustup default aarch64-apple-darwin
  rustup default stable-aarch64-apple-darwin
  cp cargo-bin/* $RUSTUP_HOME/toolchains/stable-$ARCH-apple-darwin/bin
fi

cd $PACKAGES
git clone https://github.com/quietvoid/dovi_tool.git
cd dovi_tool/dolby_vision
mkdir build
cargo cinstall \
  --manifest-path=Cargo.toml \
  --prefix="$DIR/opt" \
  --target=$ARCH-apple-darwin \
  --release \
  --library-type=staticlib

#sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libdovi.tar.xz -C $DIR/opt .
