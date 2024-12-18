y#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Library to read and write Dolby Vision metadata (C-API)
if [ ! -d "$TOOLS/rust/.cargo" ]; then
  export RUSTUP_HOME="${TOOLS}/rust/.rustup"
  export CARGO_HOME="${TOOLS}/rust/.cargo"
  curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain stable --target x86_64-apple-darwin --no-modify-path
  if [ "$(uname -m)" == "x86_64" ]; then
    $CARGO_HOME/bin/cargo install cargo-c
    #$CARGO_HOME/bin/cargo install --version "0.9.31+cargo-0.78" cargo-c
    #curl -OL https://github.com/lu-zero/cargo-c/releases/download/v0.9.31/cargo-c-macos.zip
    #7z x cargo-c-macos.zip -o$RUSTUP_HOME/toolchains/stable-$ARCH-apple-darwin/bin
  else
    curl -OL https://github.com/lu-zero/cargo-c/releases/latest/download/cargo-c-macos.zip
    7z x cargo-c-macos.zip -o$RUSTUP_HOME/toolchains/stable-$ARCH-apple-darwin/bin
  fi  
fi

if [ ! -d "$TOOLS/rust/.rustup" ]; then
  #$TOOLS/rust/.cargo/bin/rustup default stable-x86_64-apple-darwin
  $TOOLS/rust/.cargo/bin/rustup target add aarch64-apple-darwin
fi

PATH="$TOOLS/rust/.rustup/toolchains/stable-aarch64-apple-darwin/bin:$PATH"
cd $PACKAGES
git clone https://github.com/quietvoid/dovi_tool.git
cd dovi_tool/dolby_vision
mkdir build
#export LD_PRELOAD=""
export CARGO_BUILD_TARGET_DIR=build
export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1
cargo cinstall \
  --manifest-path=Cargo.toml \
  --prefix="$DIR/opt" \
  --target=$ARCH-apple-darwin \
  --release \
  --library-type=staticlib

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libdovi.tar.xz -C $DIR/opt .
