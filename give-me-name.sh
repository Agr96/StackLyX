#!/data/data/com.termux/files/usr/bin/bash

echo -n "[📛] Enter your project name (e.g. golang): "
read NAME

SAFE_NAME=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_-')
START_FILE="start-${SAFE_NAME}.sh"
STOP_FILE="stop-${SAFE_NAME}.sh"

# --- Finalized START script ---
cat > "$START_FILE" <<EOF
#!/data/data/com.termux/files/usr/bin/bash

SESSION_NAME=$SAFE_NAME
PROJECT_DIR="\$(dirname "\$(realpath "\$0")")"
VENV_DIR="\$PROJECT_DIR/.venv"
LOG_DIR="\$PROJECT_DIR/log"

mkdir -p "\$LOG_DIR"

# Check for existing session
if tmux has-session -t "\$SESSION_NAME" 2>/dev/null; then
  echo "[⚠️] Tmux session '\$SESSION_NAME' already running. Attaching..."
  tmux attach -t "\$SESSION_NAME"
  exit 0
fi

# Activate logging with new index
LOG_INDEX=\$(find "\$LOG_DIR" -type f -name "session-*.log" | wc -l)
LOG_FILE="\$LOG_DIR/session-\$(printf "%03d" \$((LOG_INDEX + 1))).log"

TMUX_COMMAND="cd '\$PROJECT_DIR' && source '\$VENV_DIR/bin/activate' && exec bash"
tmux new-session -d -s "\$SESSION_NAME" "script -f '\$LOG_FILE' -c '\$TMUX_COMMAND'"
tmux attach -t "\$SESSION_NAME"
EOF

# --- Finalized STOP script ---
cat > "$STOP_FILE" <<EOF
#!/data/data/com.termux/files/usr/bin/bash

SESSION_NAME=$SAFE_NAME
PROJECT_DIR="\$(dirname "\$(realpath "\$0")")"

if [ -n "\$TMUX" ]; then
  echo "[⚠️] You're inside tmux. Please detach first (Ctrl+b then d)."
  exit 1
fi

if ! tmux has-session -t "\$SESSION_NAME" 2>/dev/null; then
  echo "[⚠️] No tmux session named '\$SESSION_NAME' is currently running."
  exit 1
fi

echo "[🛑] Stopping tmux session: \$SESSION_NAME"
tmux kill-session -t "\$SESSION_NAME"
echo "[✅] Session stopped."

# Deactivate lingering venv if active
PYTHON_PATH=\$(which python)
if echo "\$PYTHON_PATH" | grep -q "\$PROJECT_DIR/.venv"; then
  echo "[🧹] Deactivating lingering venv..."
  deactivate 2>/dev/null
fi
EOF

# Make executable
chmod +x "$START_FILE" "$STOP_FILE"

echo "[✅] Generated: $START_FILE & $STOP_FILE"
echo "[🧨] Removing generator script..."
rm -- "\${0}"
