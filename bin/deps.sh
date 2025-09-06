#!/bin/bash

check_deps() {
    local deps=("$@")
    for dep in "${deps[@]}"; do
        if ! [ -d "$BUILD_DIR/$dep" ]; then
            info "Dependência $dep não encontrada. Construindo..."
            build_package "$dep"
        fi
    done
}
