alias t='toolbox'

dev() {
    if [ "$1" = "--session" ] && [ -n "$2" ]; then
        # Attach to (or create) a tmux session by name inside the devenv toolbox
        toolbox run -c devenv tmux new-session -A -s "$2"
    else
        toolbox enter devenv "$@"
    fi
}
