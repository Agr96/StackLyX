#!/data/data/com.termux/files/usr/bin/bash

# Warna
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RESET="\033[0m"

# Input nama proyek
echo -e "${CYAN}[📛] Masukkan nama proyek Anda (misalnya: golang, Crud, myApp):${RESET}"
read -r NAME

# Penamaan file
START="start-${NAME}.sh"
STOP="stop-${NAME}.sh"
PROJECT_DIR="\$HOME/projects/${NAME}"
LOG_DIR="\$PROJECT_DIR/log"

# ─── File START ─────────────────────────────────────────────────────────────
cat <<EOF > "\$START"
#!/data/data/com.termux/files/usr/bin/bash

NAME="${NAME}"
SESSION="\$NAME"
PROJECT_DIR="\$HOME/projects/\$NAME"
LOG_DIR="\$PROJECT_DIR/log"
LOG_INDEX=\$(printf "%03d" \$((\$(ls "\$LOG_DIR"/session-*.log 2>/dev/null | wc -l) + 1)))
LOG_FILE="\$LOG_DIR/session-\$LOG_INDEX.log"

mkdir -p "\$LOG_DIR"

echo -e "[🚀] Memulai sesi tmux: \$SESSION"

if [ ! -d "\$PROJECT_DIR" ]; then
  echo -e "[❌] Direktori proyek '\$PROJECT_DIR' tidak ditemukan."
  exit 1
fi

tmux new-session -d -s "\$SESSION" "
  cd '\$PROJECT_DIR' && \
  python -m venv .venv && \
  source .venv/bin/activate && \
  script -q '\$LOG_FILE' bash
"

if tmux has-session -t "\$SESSION" 2>/dev/null; then
  tmux attach -t "\$SESSION"
else
  echo -e "[❌] Gagal membuat tmux session '\$SESSION'."
fi
EOF

# ─── File STOP ──────────────────────────────────────────────────────────────
cat <<EOF > "\$STOP"
#!/data/data/com.termux/files/usr/bin/bash

NAME="${NAME}"
SESSION="\$NAME"
PROJECT_DIR="\$HOME/projects/\$NAME"
VENV_PATH="\$PROJECT_DIR/.venv"
LOG_DIR="\$PROJECT_DIR/log"
LAST_LOG=\$(ls -t "\$LOG_DIR"/session-*.log 2>/dev/null | head -n 1)

if ! tmux has-session -t "\$SESSION" 2>/dev/null; then
  echo -e "[⚠️] Tidak ada sesi tmux bernama '\$SESSION'."
  exit 0
fi

echo -e "[🛑] Menghentikan sesi tmux: \$SESSION"
tmux kill-session -t "\$SESSION"

if [ -d "\$VENV_PATH" ]; then
  echo -e "[🧹] Menghapus virtualenv..."
  rm -rf "\$VENV_PATH"
fi

if [ -f "\$LAST_LOG" ]; then
  echo -e "[📄] Log terakhir disimpan di: \$LAST_LOG"
fi

echo -e "[✅] Semua proses untuk '\$SESSION' telah dihentikan."
EOF

# ─── Tutorial Mewah ─────────────────────────────────────────────────────────
echo -e ""
echo -e "${YELLOW}[📖] Tutorial Lengkap: Menjalankan & Mengelola Proyek dengan Isolasi Sempurna${RESET}"
echo -e "${YELLOW}───────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "${GREEN}✔ Anda telah berhasil membuat dua skrip otomatis untuk proyek Anda:${RESET}"
echo -e ""
echo -e "   → ${CYAN}./${START}${RESET}"
echo -e "   → ${CYAN}./${STOP}${RESET}"
echo -e ""
echo -e "${YELLOW}Langkah-langkah awal menjalankan proyek ini:${RESET}"
echo -e ""
echo -e "1. 🟢 MENJALANKAN PROYEK (Start)"
echo -e "   Jalankan perintah berikut:"
echo -e "       ${GREEN}./${START}${RESET}"
echo -e ""
echo -e "   Ini akan melakukan:"
echo -e "     • Membuat virtual environment Python khusus proyek ini."
echo -e "     • Memulai session ${CYAN}tmux${RESET} bernama sesuai nama proyek."
echo -e "     • Menyimpan seluruh aktivitas session ke file log secara otomatis."
echo -e "     • Memberikan shell bersih tanpa berbagi dengan proyek lain."
echo -e ""
echo -e "2. 🟡 KELUAR SEMENTARA DARI SESI (Detach)"
echo -e "   Saat sedang berada di dalam session, tekan:"
echo -e "       ${GREEN}Ctrl + B${RESET} lalu tekan ${GREEN}D${RESET}"
echo -e "   → Ini akan meninggalkan tmux, tapi session tetap berjalan di background."
echo -e ""
echo -e "3. 🔄 KEMBALI KE SESI YANG TERTUNDA (Reattach)"
echo -e "   Gunakan perintah:"
echo -e "       ${GREEN}tmux attach -t ${NAME}${RESET}"
echo -e "   → Lanjutkan pekerjaan Anda persis seperti sebelumnya."
echo -e ""
echo -e "4. 🔴 MEMBERHENTIKAN PROYEK SEPENUHNYA (Stop)"
echo -e "   Saat proyek selesai, jalankan:"
echo -e "       ${GREEN}./${STOP}${RESET}"
echo -e ""
echo -e "   Ini akan:"
echo -e "     • Mematikan session tmux."
echo -e "     • Menonaktifkan virtual environment."
echo -e "     • Menyimpan log ke folder ${CYAN}log/session-XXX.log${RESET}."
echo -e ""
echo -e "5. ⬆ MENGIRIM 1 FILE KE GITHUB (Push One File)"
echo -e "   Gunakan langkah berikut:"
echo -e "       ${GREEN}git add nama_file${RESET}"
echo -e "       ${GREEN}git commit -m \"deskripsi perubahan\"${RESET}"
echo -e "       ${GREEN}git push${RESET}"
echo -e ""
echo -e "${YELLOW}───────────────────────────────────────────────────────────────────────────────${RESET}"
echo -e "${CYAN}💡 Catatan:${RESET}"
echo -e " • Setiap proyek berada di lingkungan terisolasi — tidak ada virtualenv atau server lokal yang tercampur."
echo -e " • Cocok untuk Python, Go, PHP, NodeJS, Flask, React, dan proyek multi-bahasa lainnya."
echo -e " • Log disimpan otomatis untuk keperluan debugging atau jejak kerja."
echo -e ""

# ─── Ubah jadi executable & hapus diri sendiri ──────────────────────────────
chmod +x "\$START" "\$STOP"

# Hapus diri sendiri
SCRIPT_PATH="$(realpath "$0")"
echo -e "${RED}[🧨] Menghapus skrip generator ini...${RESET}"
rm -f "$SCRIPT_PATH"
