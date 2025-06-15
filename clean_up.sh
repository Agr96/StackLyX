#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RESET='\033[0m'

PROJECT_DIR="$(dirname "$(realpath "$0")")/.."
BACKUP_DIR="$PROJECT_DIR/backup"
LOG_DIR="$PROJECT_DIR/log"
TMP_DIR="$PROJECT_DIR/tmp"
CORE_DIR="$PROJECT_DIR/core"

echo -e "${CYAN}──── CLEAN UP TOOL ────${RESET}"

# Konfirmasi
echo -e "${YELLOW}[⚠️] Ini akan menghapus semua log, backup, dan folder tmp"
echo -ne "${YELLOW}Lanjutkan? (y/N): ${RESET}"
read -r CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo -e "${RED}[❌] Dibatalkan.${RESET}"
  exit 1
fi

# Hapus log
if [[ -d "$LOG_DIR" ]]; then
  echo -e "${GREEN}[🧹] Menghapus folder log...${RESET}"
  rm -rf "$LOG_DIR"
else
  echo -e "${YELLOW}[ℹ️] Folder log tidak ditemukan.${RESET}"
fi

# Hapus backup
if [[ -d "$BACKUP_DIR" ]]; then
  echo -e "${GREEN}[🧹] Menghapus folder backup...${RESET}"
  rm -rf "$BACKUP_DIR"
else
  echo -e "${YELLOW}[ℹ️] Folder backup tidak ditemukan.${RESET}"
fi

# Hapus tmp
if [[ -d "$TMP_DIR" ]]; then
  echo -e "${GREEN}[🧹] Menghapus folder tmp...${RESET}"
  rm -rf "$TMP_DIR"
else
  echo -e "${YELLOW}[ℹ️] Folder tmp tidak ditemukan.${RESET}"
fi

# Optional: Bersihkan file tertentu di core
EXTRA_FILES=("*.bak" "*.tmp" "*~")
for PATTERN in "${EXTRA_FILES[@]}"; do
  FOUND=$(find "$CORE_DIR" -type f -name "$PATTERN")
  if [[ -n "$FOUND" ]]; then
    echo -e "${GREEN}[🧹] Menghapus file sampah '$PATTERN' di core...${RESET}"
    find "$CORE_DIR" -type f -name "$PATTERN" -delete
  fi
done

echo -e "${GREEN}[✅] Bersih-bersih selesai.${RESET}"
