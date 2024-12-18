#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Library to read and write Dolby Vision metadata (C-API)
if [ "$ARCHS" == "x86_64" ]; then
  rustup target add x86_64-apple-darwin
  #cargo install cargo-c
elif [ "$ARCHS" == "arm64" ]; then
  rustup target add aarch64-apple-darwin
  #cargo install cargo-c
fi

cd $PACKAGES
git clone https://github.com/quietvoid/dovi_tool.git
cd dovi_tool
cargo build --release \
  --manifest-path=Cargo.toml \
  --target-dir="$DIR/opt" \
  --target=$ARCH-apple-darwin

#sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libdovi.tar.xz -C $DIR/opt .
