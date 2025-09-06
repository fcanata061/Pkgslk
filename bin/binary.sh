#!/bin/bash

INSTALLED_DB="$(pwd)/packages/installed.db"
mkdir -p "$(dirname "$INSTALLED_DB")"

install_binary() {
    local pkg="$1"
    local pkg_file="$(pwd)/packages/$pkg-*.pkg.tar"
    if [[ ! -f $pkg_file ]]; then
        error "Pacote $pkg não encontrado. Construa primeiro."
        return 1
    fi

    info "Instalando $pkg com fakeroot..."
    fakeroot tar -xf "$pkg_file" -C /

    local files_list="$(mktemp)"
    tar -tf "$pkg_file" | grep -v metadata > "$files_list"
    echo "$pkg:$files_list" >> "$INSTALLED_DB"
    info "$pkg instalado e registrado!"
}

list_recipes_with_status() {
    echo "Pacotes disponíveis:"
    for dir in "$DIR/recipes"/*; do
        [[ -d "$dir" ]] || continue
        local pkg_name=$(basename "$dir")
        local status="[ ]"
        if grep -q "^$pkg_name:" "$INSTALLED_DB" 2>/dev/null; then
            status="[✔]"
        fi
        echo " $status $pkg_name"
    done
}

show_info() {
    local pkg="$1"
    local recipe_file="$DIR/recipes/$pkg/recipe.sh"
    if [[ ! -f "$recipe_file" ]]; then
        warn "Pacote $pkg não encontrado."
        return
    fi
    source "$recipe_file"
    echo "Nome: $pkg_name"
    echo "Versão: $pkg_version"
    echo "Dependências: ${pkg_deps[*]:-Nenhuma}"
    [[ -n "$pkg_desc" ]] && echo "Descrição: $pkg_desc"

    local installed=false
    if grep -q "^$pkg_name:" "$INSTALLED_DB" 2>/dev/null; then
        installed=true
    fi
    echo "Instalado: $([[ "$installed" == true ]] && echo '✔' || echo '✖')"
}

search_package() {
    local query="$1"
    echo "Resultados da busca para '$query':"
    for dir in "$DIR/recipes"/*; do
        [[ -d "$dir" ]] || continue
        local pkg_name=$(basename "$dir")
        if [[ "$pkg_name" == *"$query"* ]]; then
            local status="[ ]"
            if grep -q "^$pkg_name:" "$INSTALLED_DB" 2>/dev/null; then
                status="[✔]"
            fi
            echo " $status $pkg_name"
        fi
    done
}
