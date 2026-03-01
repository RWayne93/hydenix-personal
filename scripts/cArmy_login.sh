#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

mkdir -p "$XDG_STATE_HOME" "$XDG_CACHE_HOME/selenium"

CARMY_HOME="${CARMY_HOME:-$HOME/.local/share/carmy}"
PYTHON_BIN="${CARMY_PYTHON:-python3}"
LOG_FILE="$XDG_STATE_HOME/cArmy_login.log"

: > "$LOG_FILE"

PY_CMD=("$PYTHON_BIN" "-u" "$CARMY_HOME/cArmy_login.py")

if [ -t 1 ]; then
  "${PY_CMD[@]}" 2>&1 | tee -a "$LOG_FILE"
else
  exec "${PY_CMD[@]}" >>"$LOG_FILE" 2>&1
fi

