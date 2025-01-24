#!/bin/bash
set -e

cd "$(dirname "$0")" && cd ..
set -a; source build.env; source ver.sh; set +a

# Library to read and write Dolby Vision metadata (C-API)
export RUSTUP_HOME="${TOOLS}/rust/.rustup"
export CARGO_HOME="${TOOLS}/rust/.cargo"
if [[ "$(uname -m)" == "x86_64" ]]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --default-toolchain stable --target $ARCH-apple-darwin --no-modify-path
  curl -OL https://github.com/eko5624/mpv-mac/releases/download/tools/cargo-c-macos-x86_64.zip
  7z x cargo-c-macos-x86_64.zip
  cp cargo-c-bin/* $RUSTUP_HOME/toolchains/stable-x86_64-apple-darwin/bin
  PATH="$RUSTUP_HOME/toolchains/stable-x86_64-apple-darwin/bin:$PATH"
elif [[ "$(uname -m)" == "arm64" ]]; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain stable --target $ARCH-apple-darwin --no-modify-path
  curl -OL https://github.com/eko5624/mpv-mac/releases/download/tools/cargo-c-macos-arm64.zip
  7z x cargo-c-macos-arm64.zip
  cp cargo-c-bin/* $RUSTUP_HOME/toolchains/stable-aarch64-apple-darwin/bin
  PATH="$RUSTUP_HOME/toolchains/stable-aarch64-apple-darwin/bin:$PATH"
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

sed -i "" 's/opt/workspace/g' $DIR/opt/lib/pkgconfig/*.pc

cd $DIR
tar -zcvf libdovi.tar.xz -C $DIR/opt .
