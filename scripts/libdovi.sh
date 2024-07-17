#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Library to read and write Dolby Vision metadata (C-API)
cd $PACKAGES
if [ ! -d "$WORKSPACE/rust/.cargo" ]; then
  export RUSTUP_HOME="${WORKSPACE}"/rust/.rustup
  export CARGO_HOME="${WORKSPACE}"/rust/.cargo
  curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain stable --target x86_64-apple-darwin --no-modify-path
  curl -OL https://github.com/lu-zero/cargo-c/releases/download/v0.9.31/cargo-c-macos.zip
  #curl -OL https://github.com/lu-zero/cargo-c/releases/latest/download/cargo-c-macos.zip
  unzip cargo-c-macos.zip -d "$WORKSPACE/rust/.rustup/toolchains/stable-x86_64-apple-darwin/bin"
fi
if [ ! -d "$WORKSPACE/rust/.rustup" ]; then
  $WORKSPACE/rust/.cargo/bin/rustup default stable-x86_64-apple-darwin
fi
git clone https://github.com/quietvoid/dovi_tool.git
cd dovi_tool/dolby_vision
mkdir build
export CARGO_BUILD_TARGET_DIR=build
export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1
cargo cinstall \
  --manifest-path=Cargo.toml \
  --prefix="$DIR/opt" \
  --target=x86_64-apple-darwin \
  --release \
  --library-type=staticlib

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libdovi.tar.xz -C $DIR/opt .