#!/usr/bin/env bash
# tmux-resurrect saves empty full commands inside toolbox when procfs/ps
# cannot see the foreground process. pane_current_command is still correct,
# so copy it into the full-command field for known restorable programs.
set -euo pipefail

file="$1"
tmp="${file}.tmp"

awk -F'\t' -v OFS='\t' '
  /^pane/ && $11 == ":" && $10 ~ /^(nvim|vim|vi|view|lazygit|k9s|ssh|man|less|more|tail|top|htop|irssi|weechat|mutt|emacs)$/ {
    $11 = ":" $10
  }
  { print }
' "$file" > "$tmp"

mv "$tmp" "$file"
