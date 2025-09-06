
#!/bin/bash
pkg_name="binutils"
pkg_version="2.42"
pkg_url="https://ftp.gnu.org/gnu/binutils/binutils-$pkg_version.tar.xz"
pkg_git=""
pkg_deps=()
pkg_desc="Coleção de utilitários GNU de baixo nível (binutils)"

build() {
    BUILD_SUBDIR="$1"
    mkdir -p "$BUILD_SUBDIR"
    cd "$BUILD_SUBDIR"

    "$SRC_DIR/$pkg_name-$pkg_version/configure" \
        --prefix="$BUILD_SUBDIR" \
        --disable-nls \
        --disable-werror

    make -j$(nproc)
    make install
}
