#!/data/data/com.termux/files/usr/bin/bash

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RESET='\033[0m'

PROJECT_NAME_FILE=".project_name"
CORE_DIR="core"

# Cek argumen --no-input
NO_INPUT=0
for arg in "$@"; do
  if [[ "$arg" == "--no-input" ]]; then
    NO_INPUT=1
    break
  fi
done

get_project_name() {
  if [[ $NO_INPUT -eq 1 ]] && [[ -f "$PROJECT_NAME_FILE" ]]; then
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

get_project_name

# Pastikan folder core ada
mkdir -p "$CORE_DIR"

START="$CORE_DIR/start-${NAME}.sh"
STOP="$CORE_DIR/stop-${NAME}.sh"
PROJECT_DIR="\$HOME/projects/${NAME}"
LOG_DIR="\$PROJECT_DIR/log"

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

chmod +x "$START" "$STOP"

# Tutorial tampilkan hanya kalau bukan no-input
if [[ $NO_INPUT -eq 0 ]]; then
  echo -e ""
  echo -e "${YELLOW}[📖] Tutorial Lengkap: Menjalankan & Mengelola Proyek dengan Isolasi Sempurna${RESET}"
  echo -e "${BLUE}───────────────────────────────────────────────────────────────────────────────${RESET}"
  echo -e "${GREEN}✔ Anda telah berhasil membuat dua skrip otomatis untuk proyek Anda:${RESET}"
  echo -e ""
  echo -e "   → ${GREEN}./$START${RESET}"
  echo -e "   → ${GREEN}./$STOP${RESET}"
  echo -e ""
  echo -e "${YELLOW}Langkah-langkah awal menjalankan proyek ini:${RESET}"
  echo -e ""
  echo -e "1. 🟢 MENJALANKAN PROYEK (Start)"
  echo -e "   Jalankan perintah berikut:"
  echo -e "       ${GREEN}./$START${RESET}"
  echo -e "   Ini akan melakukan:"
  echo -e "     • Membuat virtual environment Python khusus proyek ini."
  echo -e "     • Memulai session ${BLUE}tmux${RESET} bernama sesuai nama proyek."
  echo -e "     • Menyimpan seluruh aktivitas session ke file log secara otomatis."
  echo -e "     • Memberikan shell bersih tanpa berbagi dengan proyek lain."
  echo -e ""
  echo -e "2. 🟡 KELUAR SEMENTARA DARI SESI (Detach)"
  echo -e "   Saat berada di dalam session, tekan:"
  echo -e "       ${YELLOW}Ctrl + B lalu D${RESET}"
  echo -e "   → Ini akan meninggalkan tmux, tapi session tetap berjalan di background."
  echo -e ""
  echo -e "3. 🔄 KEMBALI KE SESI YANG TERTUNDA (Reattach)"
  echo -e "   Gunakan perintah:"
  echo -e "       ${GREEN}tmux attach -t $NAME${RESET}"
  echo -e "   → Lanjutkan pekerjaan Anda persis seperti sebelumnya."
  echo -e ""
  echo -e "4. 🔴 MEMBERHENTIKAN PROYEK SEPENUHNYA (Stop)"
  echo -e "   Saat proyek selesai, jalankan:"
  echo -e "       ${RED}./$STOP${RESET}"
  echo -e "   Ini akan:"
  echo -e "     • Mematikan session tmux."
  echo -e "     • Menonaktifkan virtual environment (jika aktif)."
  echo -e "     • Menyimpan log ke folder log/session-XXX.log"
  echo -e ""
  echo -e "5. ⬆ MENGIRIM 1 FILE KE GITHUB (Push One File)"
  echo -e "   Gunakan langkah berikut:"
  echo -e "       ${GREEN}git add nama_file${RESET}"
  echo -e "       ${GREEN}git commit -m \"deskripsi perubahan\"${RESET}"
  echo -e "       ${GREEN}git push${RESET}"
  echo -e ""
  echo -e "${BLUE}───────────────────────────────────────────────────────────────────────────────${RESET}"
  echo -e "💡 Catatan:"
  echo -e " • Setiap proyek berada di lingkungan terisolasi — tidak ada virtualenv atau server lokal yang tercampur."
  echo -e " • Cocok untuk Python, Go, PHP, NodeJS, Flask, React, dan proyek multi-bahasa lainnya."
  echo -e " • Log disimpan otomatis untuk keperluan debugging atau jejak kerja."
  echo -e ""
fi

echo -e "${RED}[🧨] Menghapus skrip generator ini...${RESET}"
rm -- "$0"
