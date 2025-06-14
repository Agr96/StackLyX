#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

CORE_DIR="core"
PROJECTS_DIR="$HOME/projects"
BACKUP_DIR="backup"
PROJECT_NAME_FILE=".project_name"
RELEASE_BASE_URL="https://github.com/Agr96/StackLyX/raw/latest"
GIVE_ME_NAME_FILE="give-me-name.sh"

mkdir -p "$CORE_DIR" "$PROJECTS_DIR" "$BACKUP_DIR"

# Fungsi untuk baca nama proyek dari file atau input
get_project_name() {
  if [[ -f "$PROJECT_NAME_FILE" ]]; then
    NAME=$(cat "$PROJECT_NAME_FILE")
    echo -e "${GREEN}[✔] Nama proyek ditemukan dari $PROJECT_NAME_FILE: $NAME${RESET}"
  else
    echo -e "${BLUE}[📛] Masukkan nama proyek Anda (misal: golang):${RESET} "
    read -r NAME
    if [[ -z "$NAME" ]]; then
      echo -e "${RED}[❌] Nama proyek tidak boleh kosong!${RESET}"
      exit 1
    fi
    echo "$NAME" > "$PROJECT_NAME_FILE"
  fi
}

# Backup folder core dan projek terkait
backup_now() {
  get_project_name
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  BACKUP_NAME="${BACKUP_DIR}/backup-${NAME}-${TIMESTAMP}"
  echo -e "${YELLOW}[💾] Membuat backup di $BACKUP_NAME ...${RESET}"
  mkdir -p "$BACKUP_NAME"
  cp -r "$CORE_DIR" "$BACKUP_NAME/"
  cp -r "$PROJECTS_DIR/$NAME" "$BACKUP_NAME/projects" 2>/dev/null || echo -e "${YELLOW}⚠️  Tidak ada folder proyek untuk backup.${RESET}"
  echo -e "${GREEN}[✔] Backup selesai.${RESET}"
}

# List backup yang ada untuk rollback
list_backups() {
  ls -1 "$BACKUP_DIR" | grep "backup-${NAME}-" | sort -r
}

# Rollback pilih backup
rollback() {
  get_project_name
  local backups=($(list_backups))
  if [[ ${#backups[@]} -eq 0 ]]; then
    echo -e "${RED}[❌] Tidak ada backup tersedia untuk rollback.${RESET}"
    return
  fi
  echo -e "${BLUE}[🔄] Pilih backup rollback:${RESET}"
  select bkup in "${backups[@]}" "Cancel"; do
    if [[ "$bkup" == "Cancel" || -z "$bkup" ]]; then
      echo -e "${YELLOW}Dibatalkan.${RESET}"
      return
    fi
    echo -e "${YELLOW}[⚠️] Menghapus folder core dan proyek lama...${RESET}"
    rm -rf "$CORE_DIR"
    rm -rf "$PROJECTS_DIR/$NAME"
    echo -e "${YELLOW}[⚙️] Mengembalikan backup $bkup ...${RESET}"
    cp -r "$BACKUP_DIR/$bkup/core" ./
    cp -r "$BACKUP_DIR/$bkup/projects"/* "$PROJECTS_DIR/" 2>/dev/null || echo -e "${YELLOW}⚠️  Tidak ada folder proyek di backup.${RESET}"
    echo -e "${GREEN}[✔] Rollback selesai.${RESET}"
    break
  done
}

# Update now (backup dulu + update)
update_now() {
  get_project_name
  backup_now
  echo -e "${YELLOW}[⬇️] Mengunduh file $GIVE_ME_NAME_FILE terbaru...${RESET}"
  TMP_DIR=$(mktemp -d)
  cd "$TMP_DIR" || exit 1
  curl -fsSL -O "$RELEASE_BASE_URL/$GIVE_ME_NAME_FILE" || { echo -e "${RED}[❌] Gagal mengunduh $GIVE_ME_NAME_FILE${RESET}"; cd -; rm -rf "$TMP_DIR"; exit 1; }
  cd - || exit 1
  echo -e "${YELLOW}[🧹] Menghapus folder core lama...${RESET}"
  rm -rf "$CORE_DIR"
  mkdir -p "$CORE_DIR"
  mv "$TMP_DIR/$GIVE_ME_NAME_FILE" "$CORE_DIR/"
  chmod +x "$CORE_DIR/$GIVE_ME_NAME_FILE"
  rm -rf "$TMP_DIR"
  echo -e "${GREEN}[✔] Update selesai, file give-me-name.sh terbaru sudah ada di $CORE_DIR/${GIVE_ME_NAME_FILE}${RESET}"
}

# Menu pilihan
menu() {
  echo -e "${BLUE}=== Safe Update Menu ===${RESET}"
  PS3="Pilih opsi (1-3): "
  options=("Update now (backup dulu)" "Rollback" "Cancel")
  select opt in "${options[@]}"; do
    case $opt in
      "Update now (backup dulu)")
        update_now
        break
        ;;
      "Rollback")
        rollback
        break
        ;;
      "Cancel")
        echo -e "${YELLOW}Dibatalkan oleh user.${RESET}"
        break
        ;;
      *)
        echo -e "${RED}Pilihan tidak valid.${RESET}"
        ;;
    esac
  done
}

menu
