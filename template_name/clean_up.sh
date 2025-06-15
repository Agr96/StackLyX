#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Deteksi path script ini dan naik dua tingkat untuk ke root proyek
TMP_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$TMP_DIR")"
CORE_DIR="$PROJECT_ROOT/core"
STACKLYX_PARENT="$(dirname "$PROJECT_ROOT")/StackLyX"

echo -e "${BLUE}[🧹] Menghapus folder StackLyX lama: $STACKLYX_PARENT ...${RESET}"
rm -rf "$STACKLYX_PARENT"

# Pindah ke direktori core
echo -e "${CYAN}[📍] Pindah ke direktori core: $CORE_DIR${RESET}"
cd "$CORE_DIR" || {
  echo -e "${RED}[❌] Gagal masuk ke folder core.${RESET}"
  exit 1
}

cd "$HOME/projects/$NEWNAME"
exec bash

# Eksekusi give-me-name.sh
if [[ -f "./give-me-name.sh" ]]; then
  echo -e "${YELLOW}[⚙️] Menjalankan give-me-name.sh...${RESET}"
  ./give-me-name.sh
else
  echo -e "${RED}[❌] File give-me-name.sh tidak ditemukan.${RESET}"
  exit 1
fi
