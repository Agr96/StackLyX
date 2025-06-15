#!/data/data/com.termux/files/usr/bin/bash

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

# Path dasar
ROOT_DIR="$HOME/projects"
TEMPLATE_NAME="template_name"
SOURCE_PATH="$ROOT_DIR/StackLyX/$TEMPLATE_NAME"
TARGET_PATH="$ROOT_DIR/$TEMPLATE_NAME"

echo -e "${BLUE}[📂] Menyalin template: $TEMPLATE_NAME ke direktori proyek...${RESET}"

# Cek dan duplikat template_name
if [[ ! -d "$SOURCE_PATH" ]]; then
  echo -e "${RED}[❌] Folder template_name tidak ditemukan di StackLyX!${RESET}"
  exit 1
fi

cp -r "$SOURCE_PATH" "$TARGET_PATH"

# Jalankan tmp.sh dari dalam folder duplikat
TMP_SCRIPT="$TARGET_PATH/tmp/tmp.sh"
if [[ -f "$TMP_SCRIPT" ]]; then
  echo -e "${GREEN}[🚀] Menjalankan tmp.sh untuk lanjut ke give-me-name.sh...${RESET}"
  bash "$TMP_SCRIPT"
else
  echo -e "${RED}[❌] tmp.sh tidak ditemukan di $TMP_SCRIPT${RESET}"
  exit 1
fi

exit 0
