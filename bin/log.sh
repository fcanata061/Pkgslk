#!/bin/bash
LOG_DIR="$(pwd)/logs"
mkdir -p "$LOG_DIR"

info() { echo -e "\e[32m[INFO]\e[0m $1"; }
warn() { echo -e "\e[33m[WARN]\e[0m $1"; }
error() { echo -e "\e[31m[ERROR]\e[0m $1"; }

log() {
    local msg="$1"
    local file="$2"
    echo "$(date '+%F %T') $msg" >> "$LOG_DIR/$file.log"
}
