#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

ROOT="$HOME/projects"
SRC_TEMPLATE="template_name"
DEST_PATH="$ROOT/$SRC_TEMPLATE"
CLONE_DIR="$(dirname "$(realpath "$0")")"

echo -e "${BLUE}[📂] Menyalin template: $SRC_TEMPLATE ke direktori proyek...${RESET}"
cp -r "$CLONE_DIR/$SRC_TEMPLATE" "$ROOT/"

if [[ $? -ne 0 ]]; then
  echo -e "${RED}[❌] Gagal menyalin template.${RESET}"
  exit 1
fi

echo -e "${YELLOW}[🧹] Menghapus folder StackLyX lama akan dilakukan oleh tmp.sh...${RESET}"

# Jalankan tmp.sh yang akan melanjutkan semua proses (hapus StackLyX & jalankan give-me-name)
echo -e "${GREEN}[✅] Template berhasil disiapkan! Menjalankan konfigurasi proyek...${RESET}"
bash "$DEST_PATH/tmp/tmp.sh"
