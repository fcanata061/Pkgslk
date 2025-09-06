#!/bin/bash

INSTALLED_DB="$(pwd)/packages/installed.db"

remove_binary() {
    local pkg="$1"
    local entry=$(grep "^$pkg:" "$INSTALLED_DB")
    if [[ -z "$entry" ]]; then
        warn "$pkg não está instalado."
        return
    fi

    local file_list=$(echo "$entry" | cut -d: -f2)
    info "Removendo $pkg..."
    while read -r f; do
        [[ -f $f ]] && rm -f "$f"
        [[ -d $f ]] && rmdir "$f" 2>/dev/null || true
    done < "$file_list"

    grep -v "^$pkg:" "$INSTALLED_DB" > "${INSTALLED_DB}.tmp"
    mv "${INSTALLED_DB}.tmp" "$INSTALLED_DB"
    info "$pkg removido com sucesso!"
}

clean_all() {
    info "Limpando diretórios de trabalho..."
    rm -rf "$SRC_DIR" "$BUILD_DIR" "$PKG_DIR" "$LOG_DIR"
    mkdir -p "$SRC_DIR" "$BUILD_DIR" "$PKG_DIR" "$LOG_DIR"
    info "Limpeza concluída."
}
