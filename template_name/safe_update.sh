#!/data/data/com.termux/files/usr/bin/bash

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Validasi name.txt
if [[ ! -s "name.txt" ]]; then
  echo -e "${RED}[❌] name.txt tidak ditemukan atau kosong. Jalankan give-me-name.sh dulu.${RESET}"
  exit 1
fi
NAME=$(< name.txt)
CORE_DIR="./core"
BACKUP_ROOT="./backup-$NAME"

mkdir -p "$CORE_DIR" "$BACKUP_ROOT"

# Fungsi backup
backup_core() {
  TIMESTAMP="$(date +'%Y%m%d-%H%M%S')"
  BACKUP_DIR="$BACKUP_ROOT/core-$TIMESTAMP"
  mkdir -p "$BACKUP_DIR"
  cp -r "$CORE_DIR/"* "$BACKUP_DIR/" 2>/dev/null || true
  echo -e "${GREEN}[✔] Backup selesai -> $BACKUP_DIR${RESET}"
}

# Fungsi rollback
rollback() {
  echo -e "${CYAN}Pilih backup untuk rollback:${RESET}"
  mapfile -t LIST < <(ls -1 "$BACKUP_ROOT"/core-* 2>/dev/null)
  if [[ ${#LIST[@]} -eq 0 ]]; then
    echo -e "${YELLOW}[⚠️] Tidak ada backup tersedia.${RESET}"
    return
  fi
  select F in "${LIST[@]}" "Cancel"; do
    if [[ "$F" == "Cancel" ]]; then
      echo -e "${YELLOW}Rollback dibatalkan.${RESET}"; return
    elif [[ -n "$F" ]]; then
      rm -rf "$CORE_DIR"/*
      cp -r "$F/"* "$CORE_DIR/"
      echo -e "${GREEN}[✔] Rollback selesai ke backup: $F${RESET}"
      return
    fi
  done
}

# Fungsi update
update_now() {
  backup_core
  echo -e "${BLUE}[⬇️] Mengupdate folder core dari GitHub...${RESET}"
  
  # Hapus konten core
  rm -rf "$CORE_DIR"/*
  
  # Ambil semua file dari repo core (tidak hanya give-me-name.sh)
  # Contoh ambil file list statis. Jika dinamis, gunakan GitHub API atau wget folder index.
  FILES=("give-me-name.sh")
  for f in "${FILES[@]}"; do
    RAW_URL="https://raw.githubusercontent.com/Agr96/StackLyX/main/template_name/core/$f"
    curl -fsSL "$RAW_URL" -o "$CORE_DIR/$f" || { echo -e "${RED}[❌] Gagal download $f${RESET}"; return; }
    chmod +x "$CORE_DIR/$f"
  done
  
  echo -e "${GREEN}[✔] Update file core selesai.${RESET}"
  echo -e "${BLUE}[▶️] Menjalankan give-me-name.sh otomatis...${RESET}"
  (cd "$CORE_DIR" && ./give-me-name.sh)
}

# Menu dropdown
echo -e "${BLUE}=== safe_update.sh (Project: $NAME) ===${RESET}"
PS3="Pilih opsi (1-3): "
options=("Update Now + backup" "Rollback" "Cancel")
select opt in "${options[@]}"; do
  case $opt in
    "Update Now + backup") update_now; break;;
    "Rollback") rollback; break;;
    "Cancel") echo -e "${YELLOW}Dibatalkan.${RESET}"; break;;
    *) echo -e "${RED}Pilihan tidak valid.${RESET}";;
  esac
done
