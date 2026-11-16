#!/usr/bin/env bash
# tmux-resurrect saves empty full commands inside toolbox because ps/pgrep
# (procps) are not installed there. Recover the full command line (with args,
# e.g. "nvim .") from /proc for known restorable programs, falling back to
# pane_current_command.
set -euo pipefail

file="$1"
tmp="${file}.tmp"

full_command() {
  local pane_pid child
  pane_pid=$(tmux display-message -p -t "$1" '#{pane_pid}' 2>/dev/null) || return 0
  child=$(cat /proc/"$pane_pid"/task/*/children 2>/dev/null | awk '{print $1; exit}')
  [[ -n "$child" && -r /proc/$child/cmdline ]] || return 0
  xargs -0 bash -c 'printf "%q " "${0##*/}" "$@"' < /proc/"$child"/cmdline | sed 's/ $//'
}
export -f full_command

awk -F'\t' -v OFS='\t' '
  /^pane/ && $11 == ":" && $10 ~ /^(nvim|vim|vi|view|lazygit|k9s|ssh|man|less|more|tail|top|htop|irssi|weechat|mutt|emacs)$/ {
    target = $2 ":" $3 "." $6
    gsub(/\047/, "\047\\\047\047", target)
    cmd = ""
    c = "bash -c \047full_command \"$1\"\047 _ \047" target "\047"
    c | getline cmd
    close(c)
    $11 = ":" (cmd != "" ? cmd : $10)
  }
  { print }
' "$file" > "$tmp"

mv "$tmp" "$file"
