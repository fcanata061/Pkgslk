#!/bin/bash
pkg_name="binutils-pass1"
pkg_version="2.43.1"
pkg_url="https://ftp.gnu.org/gnu/binutils/binutils-$pkg_version.tar.xz"
pkg_deps=()
pkg_desc="Binutils (Pass 1) - parte inicial do toolchain"

build() {
    BUILD_SUBDIR="$1"
    mkdir -pv "$BUILD_SUBDIR"
    cd "$BUILD_SUBDIR"

    tar -xf "$SRC_DIR/$pkg_name/binutils-$pkg_version.tar.xz" -C "$BUILD_SUBDIR" --strip-components=1
    mkdir -v build
    cd build

    ../configure \
        --prefix=$LFS/tools \
        --with-sysroot=$LFS \
        --target=$LFS_TGT \
        --disable-nls \
        --enable-gprofng=no \
        --disable-werror

    make
    make install
}
