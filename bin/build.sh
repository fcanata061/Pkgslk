#!/bin/bash

SRC_DIR="$(pwd)/src"
BUILD_DIR="$(pwd)/build"
RECIPE_DIR="$(pwd)/recipes"

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

    mkdir -p "$SRC_DIR" "$BUILD_DIR"
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

    cd "$SRC_DIR/$pkg_name-$pkg_version"
    build "$BUILD_DIR/$pkg_name"
    info "$pkg construído com sucesso!"
}
