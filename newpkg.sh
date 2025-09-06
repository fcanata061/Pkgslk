#!/bin/bash
set -e
DIR="$(cd "$(dirname "$0")"; pwd)"

source "$DIR/bin/log.sh"
source "$DIR/bin/deps.sh"
source "$DIR/bin/build.sh"
source "$DIR/bin/remove.sh"
source "$DIR/bin/binary.sh"

INSTALLED_DB="$DIR/packages/installed.db"
mkdir -p "$(dirname "$INSTALLED_DB")"

usage() {
    echo "Uso: $0 {build|b|install|i|remove|r|rebuild|rb|rebuildall|rba|prepare|p|clean|c|list|l|info|search} <pacote>"
    exit 1
}

cmd="$1"
pkg="$2"

case "$cmd" in
    build|b) build_package "$pkg" ;;
    install|i) install_binary "$pkg" ;;
    remove|r) remove_binary "$pkg" ;;
    rebuild|rb) rebuild_package "$pkg" ;;
    rebuildall|rba) rebuild_system ;;
    prepare|p) prepare_package "$pkg" ;;
    clean|c) clean_all ;;
    list|l) list_recipes_with_status ;;
    info) show_info "$pkg" ;;
    search) search_package "$pkg" ;;
    *) usage ;;
esac
