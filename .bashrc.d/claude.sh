# cs: fuzzy-pick a Claude Code session from any folder, cd there and resume it
cs() {
    local dim=$'\e[2m' bold=$'\e[1m' cyan=$'\e[36m' reset=$'\e[0m'
    local t f cwd prompt sel

    sel=$(
        find ~/.claude/projects -maxdepth 2 -name '*.jsonl' -printf '%T@ %p\n' | sort -rn |
        while read -r t f; do
            cwd=$(jq -r 'select(.cwd).cwd' "$f" | head -1)
            cwd=${cwd#/var}  # Kinoite: /home -> /var/home
            prompt=$(jq -r 'select(.type=="user" and (.message.content|type)=="string").message.content' "$f" |
                grep -v '^<' | head -1 | tr '\t' ' ' | cut -c1-90)
            [ -z "$prompt" ] && continue
            # visible line \t cwd \t session id
            printf '%s%s%s  %s%s%s  %s[%s]%s\t%s\t%s\n' \
                "$dim" "$(date -d "@${t%.*}" '+%m-%d %H:%M')" "$reset" \
                "$bold" "$prompt" "$reset" \
                "$cyan" "${cwd/#$HOME/\~}" "$reset" \
                "$cwd" "$(basename "$f" .jsonl)"
        done |
        fzf --ansi --delimiter='\t' --with-nth=1 --no-sort \
            --prompt='session> ' --header='Enter: resume  |  type to filter by prompt or path'
    ) || return

    cd "$(cut -f2 <<<"$sel")" && claude --resume "$(cut -f3 <<<"$sel")"
}
