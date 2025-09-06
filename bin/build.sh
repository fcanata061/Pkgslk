#!/bin/bash

SRC_DIR="$(pwd)/src"
BUILD_DIR="$(pwd)/build"
RECIPE_DIR="$(pwd)/recipes"
PKG_DIR="$(pwd)/packages"
mkdir -p "$PKG_DIR"

build_package() {
    local pkg="$1"
    info "Construindo $pkg..."
    local recipe="$RECIPE_DIR/$pkg/recipe.sh"
    if [[ ! -f "$recipe" ]]; then
        error "Receita $pkg não encontrada!"
        return 1
    fi

    source "$recipe"
    check_deps "${pkg_deps[@]}"

    mkdir -p "$SRC_DIR" "$BUILD_DIR/$pkg/files"
    cd "$SRC_DIR"

    # Baixar ou atualizar fonte
    if [[ ! -d "$SRC_DIR/$pkg_name-$pkg_version" ]]; then
        if [[ -n "$pkg_git" ]]; then
            git clone "$pkg_git" "$pkg_name-$pkg_version"
        else
            wget "$pkg_url" -O "$pkg_name-$pkg_version.tar.xz"
            tar -xf "$pkg_name-$pkg_version.tar.xz"
        fi
    fi

    # Build dentro do subdir de build
    BUILD_SUBDIR="$BUILD_DIR/$pkg/files"
    mkdir -p "$BUILD_SUBDIR"
    cd "$SRC_DIR/$pkg_name-$pkg_version"
    build "$BUILD_SUBDIR"

    # Criar metadata
    echo "name=$pkg_name" > "$BUILD_DIR/$pkg/metadata"
    echo "version=$pkg_version" >> "$BUILD_DIR/$pkg/metadata"
    echo "deps=${pkg_deps[*]}" >> "$BUILD_DIR/$pkg/metadata"

    # Empacotar com fakeroot
    cd "$BUILD_DIR/$pkg"
    PKG_FILE="$PKG_DIR/$pkg_name-$pkg_version.pkg.tar"
    info "Empacotando $pkg em $PKG_FILE"
    fakeroot tar -cf "$PKG_FILE" files metadata

    info "$pkg empacotado com sucesso!"
}
