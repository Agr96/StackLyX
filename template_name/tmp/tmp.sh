#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Deteksi lokasi folder root proyek saat ini (parent dari folder ini)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
STACKLYX_DIR="$PROJECT_ROOT/../StackLyX"
GIVE_ME="$PROJECT_ROOT/core/give-me-name.sh"

echo -e "${YELLOW}[🧹] Menghapus folder StackLyX lama...${RESET}"
rm -rf "$STACKLYX_DIR"

if [[ -f "$GIVE_ME" ]]; then
  echo -e "${CYAN}[🚀] Menjalankan konfigurasi proyek via give-me-name.sh...${RESET}"
  cd "$PROJECT_ROOT/core" || {
    echo -e "${RED}[❌] Gagal masuk ke direktori core.${RESET}"
    exit 1
  }
  bash ./give-me-name.sh
else
  echo -e "${RED}[❌] File give-me-name.sh tidak ditemukan!${RESET}"
  exit 1
fi
