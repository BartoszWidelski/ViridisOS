#!/bin/bash
# tools/toolchain/build_binutils.sh
set -e
source "$(dirname "$0")/env.sh"

echo "=== Building Binutils $BINUTILS_VERSION for $TARGET ==="

cd "$WORK_DIR"

#1. Downloading
if [ ! -f "binutils-$BINUTILS_VERSION.tar.xz" ]; then
    wget "https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.xz"
fi

#2. Unpacking
tar -xf "binutils-$BINUTILS_VERSION.tar.xz"

# 3. Building (Shadow build - outside the source tree)
mkdir -p build-binutils
cd build-binutils

../binutils-$BINUTILS_VERSION/configure \
    --target="$TARGET" \
    --prefix="$PREFIX" \
    --with-sysroot \
    --disable-nls \
    --disable-werror

make -j"$JOBS"
make install

echo "Binutils installed successfully."