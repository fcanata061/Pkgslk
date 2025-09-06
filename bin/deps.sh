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
