#!/bin/bash
set -e

cd "$(dirname "$0")"
set -a; source build.env; source ver.sh; set +a

#rust
if [ ! -d "$WORKSPACE/rust/.cargo" ]; then
  export RUSTUP_HOME="${WORKSPACE}"/rust/.rustup
  export CARGO_HOME="${WORKSPACE}"/rust/.cargo
  curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain stable --target x86_64-apple-darwin --no-modify-path
  #curl -OL https://github.com/lu-zero/cargo-c/releases/download/v0.9.31/cargo-c-macos.zip
  curl -OL https://github.com/lu-zero/cargo-c/releases/latest/download/cargo-c-macos.zip
  unzip cargo-c-macos.zip -d "$WORKSPACE/rust/.rustup/toolchains/stable-x86_64-apple-darwin/bin"
fi
if [ ! -d "$WORKSPACE/rust/.rustup" ]; then
  $WORKSPACE/.cargo/bin/rustup default stable-x86_64-apple-darwin
fi
