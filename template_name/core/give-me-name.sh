#!/data/data/com.termux/files/usr/bin/bash

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

# Lokasi file name.txt (berada di root proyek, 1 tingkat di atas folder core)
ROOT_DIR="$(dirname "$(dirname "$(realpath "$0")")")"
NAME_FILE="$ROOT_DIR/name.txt"

# ─── Cek jika name.txt sudah ada ─────────────────────────────
if [[ -f "$NAME_FILE" && -s "$NAME_FILE" ]]; then
  NAME=$(cat "$NAME_FILE")
  echo -e "${BLUE}[📛] Menggunakan nama proyek sebelumnya dari name.txt: ${GREEN}$NAME${RESET}"
else
  echo -e "${BLUE}[📛] Masukkan nama proyek Anda (misal: lofi):${RESET} "
  read -r NAME
  if [[ -z "$NAME" ]]; then
    echo -e "${RED}[❌] Nama proyek tidak boleh kosong!${RESET}"
    exit 1
  fi
  echo "$NAME" > "$NAME_FILE"
fi

# ─── Definisi Path dan File ───────────────────────────────
PROJECT_DIR="$ROOT_DIR/$NAME"
CORE_DIR="$PROJECT_DIR/core"
mkdir -p "$CORE_DIR"

START="$CORE_DIR/start-${NAME}.sh"
STOP="$CORE_DIR/stop-${NAME}.sh"
LOG_DIR="\$HOME/projects/${NAME}/log"

# ─── Generate start script ─────────────────────────────
cat > "$START" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
NAME="${NAME}"
PROJECT_DIR="\$HOME/projects/\$NAME"
LOG_DIR="\$PROJECT_DIR/log"
SESSION="\$NAME"
LOG_FILE="\$LOG_DIR/session-\$(printf "%03d" \$((\$(ls -1 "\$LOG_DIR" 2>/dev/null | wc -l)+1))).log"

mkdir -p "\$LOG_DIR"
echo -e "[🚀] Memulai sesi tmux: \$SESSION"
tmux new-session -s "\$SESSION" -d "cd '\$PROJECT_DIR' && python3 -m venv .venv && source .venv/bin/activate && script -q -f '\$LOG_FILE'"
tmux attach -t "\$SESSION"
EOF

# ─── Generate stop script ─────────────────────────────
cat > "$STOP" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
NAME="${NAME}"
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

# ─── Jadikan executable ────────────────────────────────
chmod +x "$START" "$STOP"

# ─── Tutorial Lengkap ────────────────────────────────
echo -e ""
echo -e "${YELLOW}[📖] Tutorial: Mengelola Proyek ${NAME}${RESET}"
echo -e "${BLUE}────────────────────────────────────────────────────${RESET}"
echo -e "${GREEN}✔ Start: ${CORE_DIR}/start-${NAME}.sh${RESET}"
echo -e "${GREEN}✔ Stop : ${CORE_DIR}/stop-${NAME}.sh${RESET}"
echo -e ""
echo -e "🟢 Untuk menjalankan proyek: ${GREEN}./start-${NAME}.sh${RESET}"
echo -e "🔴 Untuk menghentikan proyek: ${RED}./stop-${NAME}.sh${RESET}"
echo -e ""
echo -e "${YELLOW}[💾] File log otomatis disimpan di: ${RESET}"
echo -e "       \$HOME/projects/${NAME}/log/"
echo -e ""
echo -e "${BLUE}────────────────────────────────────────────────────${RESET}"

exit 0
