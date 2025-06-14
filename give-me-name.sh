#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

echo -e "${BLUE}[📛] Masukkan nama proyek Anda (misal: lofi):${RESET} "
read -r NAME
if [[ -z "$NAME" ]]; then
  echo -e "${RED}[❌] Nama proyek tidak boleh kosong!${RESET}"
  exit 1
fi

PROJECT_ROOT="$HOME/projects/$NAME"
CORE_DIR="$PROJECT_ROOT/core"

# Cek apakah folder sudah ada
if [[ -d "$PROJECT_ROOT" ]]; then
  echo -e "${YELLOW}[⚠️] Folder proyek sudah ada: $PROJECT_ROOT${RESET}"
  echo -e "${YELLOW}Akan melanjutkan dan menimpa file core.*${RESET}"
else
  mkdir -p "$CORE_DIR"
fi

# Copy give-me-name.sh dan safe_update.sh ke root folder project
SCRIPT_SELF=$(realpath "$0")
SAFE_UPDATE_SH="$(dirname "$SCRIPT_SELF")/safe_update.sh"

# Pastikan safe_update.sh ada di folder sama
if [[ ! -f "$SAFE_UPDATE_SH" ]]; then
  echo -e "${RED}[❌] safe_update.sh tidak ditemukan di folder yang sama dengan give-me-name.sh${RESET}"
  exit 1
fi

echo -e "${GREEN}[🧩] Menyalin give-me-name.sh & safe_update.sh ke proyek root folder...${RESET}"
cp "$SCRIPT_SELF" "$PROJECT_ROOT/give-me-name.sh"
cp "$SAFE_UPDATE_SH" "$PROJECT_ROOT/safe_update.sh"
chmod +x "$PROJECT_ROOT/give-me-name.sh" "$PROJECT_ROOT/safe_update.sh"

# Generate start dan stop scripts di core dir
START="$CORE_DIR/start-$NAME.sh"
STOP="$CORE_DIR/stop-$NAME.sh"
LOG_DIR="\$HOME/projects/$NAME/log"

cat > "$START" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
NAME="$NAME"
PROJECT_DIR="\$HOME/projects/\$NAME"
LOG_DIR="$LOG_DIR"
SESSION="\$NAME"
LOG_FILE="\$LOG_DIR/session-\$(printf "%03d" \$((\$(ls -1 "\$LOG_DIR" 2>/dev/null | wc -l)+1))).log"

mkdir -p "\$LOG_DIR"
echo -e "[🚀] Memulai sesi tmux: \$SESSION"
tmux new-session -s "\$SESSION" -d "cd '\$PROJECT_DIR' && python3 -m venv .venv && source .venv/bin/activate && script -q -f '\$LOG_FILE'"
tmux attach -t "\$SESSION"
EOF

cat > "$STOP" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
NAME="$NAME"
SESSION="\$NAME"
PROJECT_DIR="\$HOME/projects/\$NAME"

if tmux has-session -t "\$SESSION" 2>/dev/null; then
  echo -e "[🛑] Menghentikan sesi tmux: \$SESSION"
  tmux kill-session -t "\$SESSION"
  echo -e "[✅] Sesi dihentikan."
else
  echo -e "[⚠️] Tidak ada sesi tmux bernama '\$SESSION'."
fi

deactivate 2>/dev/null
EOF

chmod +x "$START" "$STOP"

# Hapus folder StackLyX (hasil git clone awal)
CLONE_DIR="$(dirname "$SCRIPT_SELF")"
if [[ -d "$CLONE_DIR" ]]; then
  echo -e "${YELLOW}[🗑️] Menghapus folder git clone awal: $CLONE_DIR ...${RESET}"
  rm -rf "$CLONE_DIR"
else
  echo -e "${YELLOW}[ℹ️] Folder git clone awal tidak ditemukan atau sudah terhapus."
fi

echo -e "${GREEN}[✔] Setup proyek $NAME selesai!"
echo -e "  • Folder proyek root: $PROJECT_ROOT"
echo -e "  • Folder core: $CORE_DIR"
echo -e "  • Jalankan proyek menggunakan skrip di dalam core:"
echo -e "      $START"
echo -e "      $STOP"
echo -e "  • Gunakan safe_update.sh di folder root proyek untuk update/rollback."

exit 0
