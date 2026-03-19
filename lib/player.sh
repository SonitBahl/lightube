play_video() {
    local url="$1"
    local max_res="${MAX_RESOLUTION:-720}"
    local player="${PLAYER:-mpv}"

    "$player" --ytdl-format="bestvideo[vcodec^=avc1][height<=${max_res}]+bestaudio/best" \
        --quiet \
        "$url"
}

open_browser() {
    local url="$1"

    xdg-open "$url" >/dev/null 2>&1 &
}

view_description() {
    local url="$1"
    yt-dlp "$url" \
        --print "%(description)s" \
        --no-warnings \
        --ignore-errors 2>/dev/null | less -R
}

view_top_comments() {
    local url="$1"

    yt-dlp "$url" \
        --get-comments \
        --dump-single-json \
        --no-warnings \
        --ignore-errors 2>/dev/null | \
        awk '
          BEGIN { in_comments=0; author=""; text=""; count=0; max=20 }
          /"comments"[[:space:]]*:[[:space:]]*\\[/ { in_comments=1 }
          in_comments && /"author"[[:space:]]*:/ {
            author=$0
            sub(/^.*"author"[[:space:]]*:[[:space:]]*"/, "", author)
            sub(/".*$/, "", author)
          }
          in_comments && /"text"[[:space:]]*:/ {
            text=$0
            sub(/^.*"text"[[:space:]]*:[[:space:]]*"/, "", text)
            sub(/".*$/, "", text)
            gsub(/\\\\n/, " ", text)
            gsub(/\\\\r/, "", text)
            gsub(/\\\\t/, " ", text)
            if (author != "" && text != "" && count < max) {
              count++
              printf "%2d) %s\n    %s\n\n", count, author, text
            }
            author=""; text=""
          }
          in_comments && count >= max { exit }
        ' | less -R
}

open_channel() {
    local channel_url="$1"
    [ -z "$channel_url" ] && return 0
    xdg-open "$channel_url" >/dev/null 2>&1 &
}

video_action_menu() {
    local title="$1"
    local url="$2"
    local channel_url="$3"

    while true; do
        local choice
        choice=$(printf "Play video\nOpen in browser\nView full description\nView top comments\nOpen channel page\nBack\n" | \
            fzf \
                --height=40% \
                --layout=reverse \
                --border \
                --header="Selected: ${title}" \
                --prompt="Action > ")

        [ -z "$choice" ] && return 0

        case "$choice" in
            "Play video")
                play_video "$url"
                ;;
            "Open in browser")
                open_browser "$url"
                ;;
            "View full description")
                view_description "$url"
                ;;
            "View top comments")
                view_top_comments "$url"
                ;;
            "Open channel page")
                open_channel "$channel_url"
                ;;
            "Back")
                return 0
                ;;
        esac
    done
}

