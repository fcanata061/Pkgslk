#!/bin/bash

install_binary() {
    local pkg="$1"
    if [[ -d "$BUILD_DIR/$pkg" ]]; then
        cp -r "$BUILD_DIR/$pkg" /usr/local/
        info "$pkg instalado em /usr/local/"
    else
        error "Pacote $pkg não encontrado no build."
    fi
}
