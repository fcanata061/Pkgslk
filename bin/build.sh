#!/bin/bash

SRC_DIR="$(pwd)/src"
BUILD_DIR="$(pwd)/build"
RECIPE_DIR="$(pwd)/recipes"
PKG_DIR="$(pwd)/packages"
mkdir -p "$SRC_DIR" "$BUILD_DIR" "$PKG_DIR"

download_source() {
    local url="$1"
    local dest="$2"

    if [[ "$url" == git+* ]]; then
        git_url="${url#git+}"
        git clone "$git_url" "$dest"
    else
        local filename=$(basename "$url")
        wget "$url" -O "$filename"
        case "$filename" in
            *.tar.gz|*.tgz) tar -xzf "$filename" -C "$dest" ;;
            *.tar.bz2|*.tbz2) tar -xjf "$filename" -C "$dest" ;;
            *.tar.xz) tar -xJf "$filename" -C "$dest" ;;
            *.zip) unzip "$filename" -d "$dest" ;;
            *) echo "Formato desconhecido: $filename"; exit 1 ;;
        esac
    fi
}

apply_patches() {
    local patches=("$@")
    for p in "${patches[@]}"; do
        local patch_dir="$SRC_DIR/$pkg_name-$pkg_version"
        if [[ "$p" == git+* ]]; then
            local tmpdir=$(mktemp -d)
            git clone "${p#git+}" "$tmpdir"
            cp -r "$tmpdir"/* "$patch_dir"/
            rm -rf "$tmpdir"
        else
            wget "$p" -O /tmp/patch.tmp
            patch -d "$patch_dir" -p1 < /tmp/patch.tmp
        fi
    done
}

build_package() {
    local pkg="$1"
    info "Construindo $pkg..."
    local recipe="$RECIPE_DIR/$pkg/recipe.sh"
    if [[ ! -f "$recipe" ]]; then
        error "Receita $pkg não encontrada!"
        return 1
    fi

    local build_order=($(resolve_dependencies "$pkg"))
    for p in "${build_order[@]}"; do
        _build_single "$p"
    done
}

_build_single() {
    local pkg="$1"
    local recipe="$RECIPE_DIR/$pkg/recipe.sh"
    source "$recipe"
    check_deps "${pkg_deps[@]}"

    mkdir -p "$SRC_DIR" "$BUILD_DIR/$pkg/files"
    cd "$SRC_DIR"

    download_source "$pkg_url" "$SRC_DIR/$pkg_name-$pkg_version"
    for extra in "${pkg_extra_sources[@]}"; do
        download_source "$extra" "$SRC_DIR/$pkg_name-$pkg_version"
    done
    apply_patches "${pkg_patches[@]}"

    BUILD_SUBDIR="$BUILD_DIR/$pkg/files"
    mkdir -p "$BUILD_SUBDIR"
    cd "$SRC_DIR/$pkg_name-$pkg_version"
    build "$BUILD_SUBDIR"

    mkdir -p "$BUILD_DIR/$pkg"
    echo "name=$pkg_name" > "$BUILD_DIR/$pkg/metadata"
    echo "version=$pkg_version" >> "$BUILD_DIR/$pkg/metadata"
    echo "deps=${pkg_deps[*]}" >> "$BUILD_DIR/$pkg/metadata"
    [[ -n "$pkg_desc" ]] && echo "desc=$pkg_desc" >> "$BUILD_DIR/$pkg/metadata"

    cd "$BUILD_DIR/$pkg"
    PKG_FILE="$PKG_DIR/$pkg_name-$pkg_version.pkg.tar"
    info "Empacotando $pkg em $PKG_FILE"
    fakeroot tar -cf "$PKG_FILE" files metadata
    info "$pkg empacotado com sucesso!"
}

prepare_package() {
    local pkg="$1"
    info "Preparando compilação de $pkg (sem instalar)..."
    local recipe="$RECIPE_DIR/$pkg/recipe.sh"
    if [[ ! -f "$recipe" ]]; then
        error "Receita $pkg não encontrada!"
        return 1
    fi
    source "$recipe"
    check_deps "${pkg_deps[@]}"

    mkdir -p "$SRC_DIR" "$BUILD_DIR/$pkg/files"
    cd "$SRC_DIR"

    download_source "$pkg_url" "$SRC_DIR/$pkg_name-$pkg_version"
    for extra in "${pkg_extra_sources[@]}"; do
        download_source "$extra" "$SRC_DIR/$pkg_name-$pkg_version"
    done
    apply_patches "${pkg_patches[@]}"
    info "Preparação concluída para $pkg."
}
