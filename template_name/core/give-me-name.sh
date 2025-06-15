#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

ROOT_DIR="$HOME/projects"
CURRENT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$(dirname "$CURRENT_DIR")"
NAME_FILE="$PROJECT_ROOT/name.txt"

# Ambil nama proyek dari name.txt jika ada
if [[ -f "$NAME_FILE" && -s "$NAME_FILE" ]]; then
  NAME=$(cat "$NAME_FILE")
  echo -e "${BLUE}[🔄] Menggunakan nama proyek yang sudah ada:${RESET} ${YELLOW}$NAME${RESET}"
else
  echo -e "${BLUE}[📛] Masukkan nama proyek Anda (misal: lofi):${RESET} "
  read -r NAME
  if [[ -z "$NAME" ]]; then
    echo -e "${RED}[❌] Nama proyek tidak boleh kosong!${RESET}"
    exit 1
  fi
  echo "$NAME" > "$NAME_FILE"
fi

START="$CURRENT_DIR/start-$NAME.sh"
STOP="$CURRENT_DIR/stop-$NAME.sh"
LOG_DIR="$PROJECT_ROOT/log"

echo -e "${YELLOW}[⚙️] Menyiapkan skrip start & stop untuk proyek ...${RESET}"

cat > "$START" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
NAME="$NAME"
PROJECT_DIR="\$HOME/projects/\$NAME"
LOG_DIR="\$PROJECT_DIR/log"
SESSION="\$NAME"
LOG_FILE="\$LOG_DIR/session-\$(printf "%03d" \$((\$(ls -1 "\$LOG_DIR" 2>/dev/null | wc -l)+1))).log"

mkdir -p "\$LOG_DIR"
echo -e "[🚀] Memulai sesi tmux: \$SESSION"
tmux new-session -s "\$SESSION" -d "cd '\$PROJECT_DIR' && python3 -m venv .venv && source .venv/bin/activate && script -q -f '\$LOG_FILE'"
tmux attach -t "\$SESSION"
EOF

cat > "$STOP" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
SESSION="$NAME"

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

echo -e "${GREEN}[✅] Skrip berhasil dibuat:${RESET}"
echo -e "    $START"
echo -e "    $STOP"

# ─── Bersihkan pemicu sementara ───────────────────────────────
if [[ -d "$PROJECT_ROOT/tmp" ]]; then
  echo -e "${YELLOW}[🧹] Menghapus folder tmp setelah konfigurasi...${RESET}"
  rm -rf "$PROJECT_ROOT/tmp"
fi
