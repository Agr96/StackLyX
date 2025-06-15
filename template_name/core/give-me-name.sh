#!/data/data/com.termux/files/usr/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

PROJECT_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
NAME_FILE="$PROJECT_ROOT/name.txt"
CORE_DIR="$PROJECT_ROOT/core"
LOG_DIR="$PROJECT_ROOT/log"

# Ambil nama dari name.txt jika sudah ada
if [[ -f "$NAME_FILE" && -s "$NAME_FILE" ]]; then
  NAME=$(cat "$NAME_FILE")
  echo -e "${BLUE}[🔁] Menggunakan nama proyek yang sudah ada: ${YELLOW}$NAME${RESET}"
else
  echo -e "${BLUE}[📛] Masukkan nama proyek Anda (misal: lofi):${RESET} "
  read -r NAME
  if [[ -z "$NAME" ]]; then
    echo -e "${RED}[❌] Nama proyek tidak boleh kosong!${RESET}"
    exit 1
  fi
  echo "$NAME" > "$NAME_FILE"
fi

START="$CORE_DIR/start-$NAME.sh"
STOP="$CORE_DIR/stop-$NAME.sh"

echo -e "${BLUE}[⚙️] Menyiapkan skrip start & stop untuk proyek ...${RESET}"
mkdir -p "$LOG_DIR"

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

echo -e "${GREEN}[✅] Skrip berhasil dibuat:${RESET}"
echo -e "    $START"
echo -e "    $STOP"

# Terakhir hapus folder tmp
TMP_DIR="$PROJECT_ROOT/tmp"
if [[ -d "$TMP_DIR" ]]; then
  echo -e "${YELLOW}[🧹] Menghapus folder tmp...${RESET}"
  rm -rf "$TMP_DIR"
fi
