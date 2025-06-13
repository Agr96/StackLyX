#!/data/data/com.termux/files/usr/bin/bash

# ANSI color
BOLD="\e[1m"
RESET="\e[0m"
YELLOW="\e[33m"
GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
CYAN="\e[36m"

# Ask for project name
echo -e "${CYAN}[📛] Masukkan nama proyek Anda (misal: golang, react, flask):${RESET}"
read -r project

start_script="start-$project.sh"
stop_script="stop-$project.sh"
log_dir="./log"

# === START SCRIPT ===
cat > "$start_script" <<EOF
#!/data/data/com.termux/files/usr/bin/bash

SESSION="$project"
LOG_DIR="./log"
LOG_FILE="\$LOG_DIR/session-\$(printf "%03d" \$((\$(ls -1q \$LOG_DIR/session-*.log 2>/dev/null | wc -l)+1))).log"

mkdir -p "\$LOG_DIR"

echo -e "${GREEN}[🚀] Memulai sesi tmux: \$SESSION${RESET}"
tmux new-session -d -s "\$SESSION" \\
  "source .venv/bin/activate && exec script -q --flush --append \"\$LOG_FILE\""

sleep 1
tmux attach-session -t "\$SESSION"
EOF

# === STOP SCRIPT ===
cat > "$stop_script" <<EOF
#!/data/data/com.termux/files/usr/bin/bash

SESSION="$project"
LOG_DIR="./log"

if tmux has-session -t "\$SESSION" 2>/dev/null; then
  echo -e "${RED}[🛑] Menghentikan sesi tmux: \$SESSION${RESET}"
  tmux kill-session -t "\$SESSION"
  echo -e "${GREEN}[✅] Sesi dihentikan.${RESET}"
else
  echo -e "${YELLOW}[⚠️] Tidak ada sesi tmux bernama '\$SESSION'.${RESET}"
fi

source .venv/bin/activate 2>/dev/null && deactivate
EOF

# Buat bisa dieksekusi
chmod +x "$start_script" "$stop_script"

# === TUTORIAL ===
echo -e "
${YELLOW}${BOLD}[📖] Tutorial Lengkap: Menjalankan & Mengelola Proyek dengan Isolasi Sempurna${RESET}
───────────────────────────────────────────────────────────────────────────────
✔ Anda telah berhasil membuat dua skrip otomatis untuk proyek Anda:

   → ${BOLD}./$start_script${RESET}
   → ${BOLD}./$stop_script${RESET}

${BOLD}Langkah-langkah awal menjalankan proyek ini:${RESET}

1. 🟢 ${BOLD}MENJALANKAN PROYEK (Start)${RESET}
   Jalankan:
       ${GREEN}./$start_script${RESET}
   Ini akan:
     • Membuat virtualenv lokal
     • Memulai sesi tmux terisolasi
     • Menyimpan seluruh aktivitas ke file log

2. 🟡 ${BOLD}KELUAR SEMENTARA DARI SESI (Detach)${RESET}
   Tekan:
       ${CYAN}Ctrl + B lalu tekan D${RESET}
   → Session tetap berjalan di background

3. 🔄 ${BOLD}KEMBALI KE SESI (Reattach)${RESET}
   Jalankan:
       ${CYAN}tmux attach -t $project${RESET}
   → Anda kembali ke sesi sebelumnya

4. 🔴 ${BOLD}STOP PROYEK (Shutdown)${RESET}
   Jalankan:
       ${RED}./$stop_script${RESET}
   → Ini akan mematikan tmux & venv

5. ⬆ ${BOLD}GIT PUSH SATU FILE${RESET}
   Gunakan:
       ${BLUE}git add nama_file && git commit -m \"pesan\" && git push${RESET}

───────────────────────────────────────────────────────────────────────────────
💡 ${BOLD}Catatan:${RESET}
 • Setiap proyek punya lingkungan virtual & shell yang terpisah total
 • Semua log disimpan di ${CYAN}$log_dir/session-XXX.log${RESET}
 • Cocok untuk Python, Go, PHP, React, NodeJS, dsb.
"

# Hapus diri sendiri
SCRIPT_PATH="$(realpath "$0")"
echo -e "${RED}[🧨] Menghapus skrip generator ini...${RESET}"
rm -f "$SCRIPT_PATH"
