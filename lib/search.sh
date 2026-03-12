search() {
    query="$1"

    yt-dlp "ytsearch${RESULTS}:${query}" \
        --print "%(title)s|%(webpage_url)s" \
        --no-warnings \
        --ignore-errors 2>/dev/null
}