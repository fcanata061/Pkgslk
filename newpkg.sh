#!/bin/bash
set -e
DIR="$(cd "$(dirname "$0")"; pwd)"

source "$DIR/bin/log.sh"
source "$DIR/bin/deps.sh"
source "$DIR/bin/build.sh"
source "$DIR/bin/remove.sh"
source "$DIR/bin/binary.sh"

usage() {
    echo "Uso: $0 {build|remove|list|install|rebuild} <pacote>"
    exit 1
}

case "$1" in
    build) build_package "$2" ;;
    remove) remove_package "$2" ;;
    list) list_recipes ;;
    install) install_binary "$2" ;;
    rebuild) rebuild_package "$2" ;;
    *) usage ;;
esac
