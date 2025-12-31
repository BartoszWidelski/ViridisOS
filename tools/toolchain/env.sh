# tools/toolchain/env.sh
export TARGET=x86_64-elf
export PREFIX="$HOME/opt/cross" # Install inside a container (or user's home)
export PATH="$PREFIX/bin:$PATH"

# Versions - Single Source of Truth
export BINUTILS_VERSION=2.43
export GCC_VERSION=14.2.0

# Speed ​​up compilation (all cores)
export JOBS=$(nproc)

# Working directories
export WORK_DIR="/tmp/src"
mkdir -p "$WORK_DIR"
mkdir -p "$PREFIX"