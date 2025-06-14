#!/data/data/com.termux/files/usr/bin/bash

# Warna
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Path setup
TEMPLATE_NAME="template-name"
STACKLYX_DIR="$(dirname "$(realpath "$0")")"
SOURCE_DIR="$STACKLYX_DIR/$TEMPLATE_NAME"
DEST_DIR="$HOME/projects/$TEMPLATE_NAME"

# Duplikasi template
echo -e "${GREEN}[📂] Menyalin template: $TEMPLATE_NAME ke direktori proyek...${RESET}"
cp -r "$SOURCE_DIR" "$DEST_DIR"

# Arahkan ke folder baru
cd "$DEST_DIR" || {
  echo -e "${YELLOW}[❌] Gagal masuk ke direktori $DEST_DIR${RESET}"
  exit 1
}

# Hapus StackLyX (termasuk run_me.sh)
echo -e "${YELLOW}[🧹] Menghapus folder StackLyX lama...${RESET}"
rm -rf "$STACKLYX_DIR"

# Arahkan ke folder core/
echo -e "${CYAN}[✅] Template berhasil disiapkan! Sekarang masuk ke folder core:${RESET}"
cd core
echo -e "${CYAN}📍 Sekarang Anda berada di: $(pwd)${RESET}"
echo -e "${YELLOW}➡ Jalankan: ./give-me-name.sh${RESET}"
