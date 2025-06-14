#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

# Folder proyek root: lokasi safe_update.sh sekarang
PROJECT_ROOT=$(dirname "$(realpath "$0")")
BACKUP_DIR="$PROJECT_ROOT/backups"
CORE_DIR="$PROJECT_ROOT/core"
GIVE_ME_NAME_SH="$PROJECT_ROOT/give-me-name.sh"

# URL rilis untuk update (ganti sesuai repo Anda)
RELEASE_URL="https://raw.githubusercontent.com/Agr96/StackLyX/latest/give-me-name.sh"

# Fungsi membuat backup folder core + safe_update.sh + give-me-name.sh
function backup() {
  mkdir -p "$BACKUP_DIR"
  TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
  BACKUP_NAME="backup-$TIMESTAMP.tar.gz"
  echo -e "${YELLOW}[💾] Membuat backup ke $BACKUP_NAME ...${RESET}"
  tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$PROJECT_ROOT" core safe_update.sh give-me-name.sh
  echo -e "${GREEN}[✔] Backup selesai.${RESET}"
}

# Fungsi rollback backup terpilih
function rollback() {
  echo -e "${YELLOW}[🔄] Pilih backup untuk rollback:${RESET}"
  mapfile -t BACKUPS < <(ls -1 "$BACKUP_DIR"/backup-*.tar.gz 2>/dev/null)
  if [[ ${#BACKUPS[@]} -eq 0 ]]; then
    echo -e "${RED}[❌] Tidak ada backup tersedia untuk rollback.${RESET}"
    return
  fi

  select choice in "${BACKUPS[@]}" "Cancel"; do
    if [[ "$choice" == "Cancel" || -z "$choice" ]]; then
      echo "Rollback dibatalkan."
      return
    elif [[ -n "$choice" ]]; then
      echo -e "${YELLOW}[⏳] Melakukan rollback dengan backup: $choice ...${RESET}"
      # Hapus folder core dan safe_update.sh serta give-me-name.sh sementara
      rm -rf "$CORE_DIR"
      rm -f "$PROJECT_ROOT/safe_update.sh" "$PROJECT_ROOT/give-me-name.sh"
      # Extract backup ke root proyek
      tar -xzf "$choice" -C "$PROJECT_ROOT"
      echo -e "${GREEN}[✔] Rollback selesai!${RESET}"
      return
    else
      echo "Pilihan tidak valid."
    fi
  done
}

# Fungsi update sekarang (backup dulu, lalu ambil give-me-name.sh baru)
function update_now() {
  backup
  echo -e "${YELLOW}[⬇️] Mengunduh give-me-name.sh terbaru dari $RELEASE_URL ...${RESET}"
  curl -fsSL "$RELEASE_URL" -o "$GIVE_ME_NAME_SH"
  if [[ $? -eq 0 ]]; then
    chmod +x "$GIVE_ME_NAME_SH"
    echo -e "${GREEN}[✔] Update give-me-name.sh selesai.${RESET}"
  else
    echo -e "${RED}[❌] Gagal mengunduh give-me-name.sh.${RESET}"
  fi
}

# Menu pilihan utama
echo -e "${BLUE}=== Safe Update Script ===${RESET}"
echo "Pilih opsi:"
options=("Update Now (Backup dulu)" "Rollback" "Cancel")

select opt in "${options[@]}"; do
  case $opt in
    "Update Now (Backup dulu)")
      update_now
      break
      ;;
    "Rollback")
      rollback
      break
      ;;
    "Cancel")
      echo "Dibatalkan."
      break
      ;;
    *)
      echo "Pilihan tidak valid, coba lagi."
      ;;
  esac
done
