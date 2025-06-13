#!/data/data/com.termux/files/usr/bin/bash

read -p "[📛] Enter your project name (e.g. golang): " project_name

START_SCRIPT="start-$project_name.sh"
STOP_SCRIPT="stop-$project_name.sh"

cat > "$START_SCRIPT" <<EOF
#!/data/data/com.termux/files/usr/bin/bash

SESSION_NAME="$project_name"
PROJECT_DIR="\$(pwd)"
LOG_DIR="\$PROJECT_DIR/log"

mkdir -p "\$LOG_DIR"

LOG_INDEX=\$(printf "%03d" \$(( \$(ls "\$LOG_DIR" | wc -l) + 1 )))
LOG_FILE="\$LOG_DIR/session-\$LOG_INDEX.log"

if tmux has-session -t "\$SESSION_NAME" 2>/dev/null; then
  echo "[⚠️] Session '\$SESSION_NAME' already exists. Use 'tmux attach -t \$SESSION_NAME'"
  exit 1
fi

echo "[🚀] Starting tmux session: \$SESSION_NAME"
script -q -f "\$LOG_FILE" --command "tmux new-session -s '\$SESSION_NAME' \\
  'python -m venv .venv && \\
   source .venv/bin/activate && \\
   echo \"[💡] Python now pointing to: \\\$(which python)\" && \\
   exec bash'"

EOF

cat > "$STOP_SCRIPT" <<EOF
#!/data/data/com.termux/files/usr/bin/bash

SESSION_NAME="$project_name"
PROJECT_DIR="\$(pwd)"
LOG_DIR="\$PROJECT_DIR/log"

if tmux has-session -t "\$SESSION_NAME" 2>/dev/null; then
  echo "[🛑] Stopping tmux session: \$SESSION_NAME"
  tmux kill-session -t "\$SESSION_NAME"
  echo "[✅] Session stopped."
else
  echo "[⚠️] No tmux session named '\$SESSION_NAME' is currently running."
  exit 0
fi

if [[ -n "\$VIRTUAL_ENV" ]]; then
  deactivate 2>/dev/null
fi
EOF

chmod +x "$START_SCRIPT" "$STOP_SCRIPT"

# Tutorial singkat sebelum hapus diri
echo ""
echo "[📖] Tutorial Singkat:"
echo " • Untuk menjalankan project: ./start-$project_name.sh"
echo " • Setelah masuk tmux: tekan Ctrl+B lalu D (detach)"
echo " • Untuk kembali ke session: tmux attach -t $project_name"
echo " • Untuk keluar dan mematikan semuanya: ./stop-$project_name.sh"
echo " • Untuk push 1 file: git add nama_file && git commit -m '...' && git push"
echo ""

# Auto-remove this script
echo "[✅] Generated: $START_SCRIPT & $STOP_SCRIPT"
echo "[🧨] Removing generator script..."
rm -- "\$0"
