#!/bin/bash

remove_package() {
    local pkg="$1"
    if [[ -d "$BUILD_DIR/$pkg" ]]; then
        rm -rf "$BUILD_DIR/$pkg"
        rm -rf "/usr/local/$pkg"
        info "$pkg removido."
    else
        warn "$pkg não encontrado."
    fi
}
