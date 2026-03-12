play_video() {
    local url="$1"
    local max_res="${MAX_RESOLUTION:-720}"

    mpv --ytdl-format="bestvideo[vcodec^=avc1][height<=${max_res}]+bestaudio/best" \
        --quiet \
        "$url"
}

open_browser() {
    local url="$1"

    xdg-open "$url" >/dev/null 2>&1 &
}

video_action_menu() {
    local url="$1"

    while true; do
        local choice
        choice=$(printf "Play Video\nOpen in Browser\nBack to Results\n" | \
            fzf \
                --height=40% \
                --layout=reverse \
                --border \
                --prompt="Action > ")

        [ -z "$choice" ] && return 0

        case "$choice" in
            "Play Video")
                play_video "$url"
                ;;
            "Open in Browser")
                open_browser "$url"
                ;;
            "Back to Results")
                return 0
                ;;
        esac
    done
}

