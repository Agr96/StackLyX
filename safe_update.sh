#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Baca nama proyek dari name.txt
ROOT_DIR="$(dirname "$(realpath "$0")")"
NAME_FILE="$ROOT_DIR/name.txt"
if [[ ! -f "$NAME_FILE" ]]; then
  echo -e "${RED}[❌] name.txt tidak ditemukan!${RESET}"
  exit 1
fi

PROJECT_NAME=$(<"$NAME_FILE")
CORE_DIR="$ROOT_DIR/core"
BACKUP_DIR="$ROOT_DIR/backup"

REPO_RAW_BASE="https://raw.githubusercontent.com/Agr96/StackLyX/main/template_name/core"
GIVE_ME_NAME_URL="$REPO_RAW_BASE/give-me-name.sh"

# Fungsi untuk update dan backup
update_now() {
  echo -e "${YELLOW}[📦] Membackup isi folder core...${RESET}"
  mkdir -p "$BACKUP_DIR"
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  BACKUP_FILE="$BACKUP_DIR/core_backup_$TIMESTAMP.tar.gz"
  tar -czf "$BACKUP_FILE" -C "$CORE_DIR" .

  echo -e "${YELLOW}[🧹] Menghapus isi folder core lama...${RESET}"
  find "$CORE_DIR" -mindepth 1 -delete

  echo -e "${BLUE}[⬇] Mengunduh file terbaru dari repo...${RESET}"
  curl -sL "$GIVE_ME_NAME_URL" -o "$CORE_DIR/give-me-name.sh"
  chmod +x "$CORE_DIR/give-me-name.sh"

  echo -e "${GREEN}[✅] Update selesai. Menjalankan konfigurasi proyek...${RESET}"
  cd "$CORE_DIR" && ./give-me-name.sh
}

# Fungsi untuk rollback
rollback() {
  echo -e "${BLUE}[📂] Daftar backup tersedia:${RESET}"
  if ! ls "$BACKUP_DIR"/*.tar.gz 1>/dev/null 2>&1; then
    echo -e "${RED}[❌] Tidak ada backup tersedia.${RESET}"
    exit 1
  fi

  ls -1 "$BACKUP_DIR" | nl
  echo -ne "\n${YELLOW}[?] Pilih nomor backup untuk rollback: ${RESET}"
  read -r ROLLNUM
  SELECTED=$(ls -1 "$BACKUP_DIR" | sed -n "${ROLLNUM}p")
  if [[ -z "$SELECTED" ]]; then
    echo -e "${RED}[❌] Nomor tidak valid.${RESET}"
    exit 1
  fi
  echo -e "${YELLOW}[🔄] Melakukan rollback dengan $SELECTED...${RESET}"
  find "$CORE_DIR" -mindepth 1 -delete
  tar -xzf "$BACKUP_DIR/$SELECTED" -C "$CORE_DIR"
  echo -e "${GREEN}[✅] Rollback selesai.${RESET}"
}

# Menu
clear
echo -e "${CYAN}──── SAFE UPDATE MENU ────${RESET}"
echo -e "${YELLOW}1) Update now + Backup"
echo -e "2) Rollback (lihat backup)"
echo -e "3) Cancel${RESET}"
echo -ne "\n${BLUE}Pilih opsi [1-3]: ${RESET}"
read -r CHOICE

case $CHOICE in
  1) update_now;;
  2) rollback;;
  3) echo -e "${YELLOW}[⚠️] Update dibatalkan.${RESET}"; exit 0;;
  *) echo -e "${RED}[❌] Pilihan tidak valid.${RESET}"; exit 1;;
esac
