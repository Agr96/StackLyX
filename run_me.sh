#!/data/data/com.termux/files/usr/bin/bash

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Lokasi dan nama template
ROOT="$HOME/projects"
TEMPLATE="template_name"
SRC_DIR="$ROOT/StackLyX/$TEMPLATE"
DEST_DIR="$ROOT/$TEMPLATE"

# Cek eksistensi folder source
if [[ ! -d "$SRC_DIR" ]]; then
  echo -e "${RED}[❌] Folder template tidak ditemukan di: $SRC_DIR${RESET}"
  exit 1
fi

# Menyalin template ke direktori project
echo -e "${BLUE}[📂] Menyalin template: $TEMPLATE ke direktori proyek...${RESET}"
cp -r "$SRC_DIR" "$DEST_DIR"

# Menghapus folder StackLyX (bukan dijalankan otomatis lagi oleh skrip lain)
echo -e "${YELLOW}[🧹] Menghapus folder StackLyX lama...${RESET}"
rm -rf "$ROOT/StackLyX"

# Panduan setelah setup
echo -e "${GREEN}[✅] Template berhasil disiapkan!${RESET}"
echo -e "${CYAN}📍 Sekarang Anda berada di: $DEST_DIR"
echo -e "➡ Jalankan skrip berikut secara manual:"
echo -e "   cd $DEST_DIR/core"
echo -e "   ./give-me-name.sh${RESET}"
