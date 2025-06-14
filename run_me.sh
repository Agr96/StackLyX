#!/data/data/com.termux/files/usr/bin/bash

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Lokasi kerja
ROOT_DIR="$HOME/projects"
STACKLYX_DIR="$ROOT_DIR/StackLyX"
TEMPLATE_NAME="template_name"
TEMPLATE_PATH="$STACKLYX_DIR/$TEMPLATE_NAME"
DEST_PATH="$ROOT_DIR/$TEMPLATE_NAME"

# ─── Salin Template ─────────────────────────────────────────────
echo -e "${BLUE}[📂] Menyalin template: $TEMPLATE_NAME ke direktori proyek...${RESET}"
if [[ -d "$TEMPLATE_PATH" ]]; then
  cp -r "$TEMPLATE_PATH" "$DEST_PATH"
else
  echo -e "${RED}[❌] Folder template tidak ditemukan di: $TEMPLATE_PATH${RESET}"
  exit 1
fi

# ─── Hapus StackLyX ─────────────────────────────────────────────
echo -e "${YELLOW}[🧹] Menghapus folder StackLyX lama...${RESET}"
rm -rf "$STACKLYX_DIR"

# ─── Masuk ke /core dan eksekusi give-me-name.sh ───────────────
cd "$DEST_PATH/core" || {
  echo -e "${RED}[❌] Gagal masuk ke direktori $DEST_PATH/core${RESET}"
  exit 1
}

if [[ -f "give-me-name.sh" ]]; then
  chmod +x give-me-name.sh
  echo -e "${GREEN}[✅] Template berhasil disiapkan! Menjalankan konfigurasi proyek...${RESET}"
  ./give-me-name.sh
else
  echo -e "${RED}[❌] give-me-name.sh tidak ditemukan di $DEST_PATH/core${RESET}"
  exit 1
fi
