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

    # Registrar arquivos instalados
    local files_list="$(mktemp)"
    tar -tf "$pkg_file" | grep -v metadata > "$files_list"

    echo "$pkg:$files_list" >> "$INSTALLED_DB"
    info "$pkg instalado e registrado!"
}

# Função para remover pacotes instalados
remove_binary() {
    local pkg="$1"
    local entry=$(grep "^$pkg:" "$INSTALLED_DB")
    if [[ -z "$entry" ]]; then
        warn "Pacote $pkg não está instalado."
        return
    fi

    local file_list=$(echo "$entry" | cut -d: -f2)
    info "Removendo $pkg..."
    while read -r f; do
        [[ -f $f ]] && rm -f "$f"
        [[ -d $f ]] && rmdir "$f" 2>/dev/null || true
    done < "$file_list"

    # Remover do DB
    grep -v "^$pkg:" "$INSTALLED_DB" > "${INSTALLED_DB}.tmp"
    mv "${INSTALLED_DB}.tmp" "$INSTALLED_DB"
    info "$pkg removido com sucesso!"
}
