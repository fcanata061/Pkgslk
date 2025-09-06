#!/bin/bash

check_deps() {
    local deps=("$@")
    for dep in "${deps[@]}"; do
        if ! grep -q "^$dep:" "$INSTALLED_DB" 2>/dev/null; then
            info "Dependência $dep não encontrada. Construindo..."
            build_package "$dep"
        fi
    done
}

resolve_dependencies() {
    local pkg="$1"
    local visited=()
    local order=()

    _visit() {
        local p="$1"
        local recipe_file="$DIR/recipes/$p/recipe.sh"
        if [[ ! -f "$recipe_file" ]]; then
            error "Receita $p não encontrada para resolver dependências."
            exit 1
        fi
        source "$recipe_file"
        for dep in "${pkg_deps[@]}"; do
            if [[ ! " ${visited[*]} " =~ " $dep " ]]; then
                visited+=("$dep")
                _visit "$dep"
            fi
        done
        if [[ ! " ${order[*]} " =~ " $p " ]]; then
            order+=("$p")
        fi
    }

    _visit "$pkg"
    echo "${order[@]}"
}
