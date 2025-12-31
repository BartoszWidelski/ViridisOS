#!/bin/bash
# tools/toolchain/build_gcc.sh
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building GCC $GCC_VERSION for $TARGET ==="

cd "$WORK_DIR"

#1. Downloading
if [ ! -f "gcc-$GCC_VERSION.tar.xz" ]; then
    wget "https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz"
fi

#2. Unpacking
tar -xf "gcc-$GCC_VERSION.tar.xz"

# 3. Building (Shadow build)
mkdir -p build-gcc
cd build-gcc

# NOTE: We only build gcc and libgcc (basic support)
../gcc-$GCC_VERSION/configure \
    --target="$TARGET" \
    --prefix="$PREFIX" \
    --disable-nls \
    --enable-languages=c,c++ \
    --without-headers \
    --disable-hosted-libstdcxx \
    --disable-libssp \
    --disable-shared \
    --disable-threads

make -j"$JOBS" all-gcc
make -j"$JOBS" all-target-libgcc
make install-gcc
make install-target-libgcc

echo "GCC installed successfully."