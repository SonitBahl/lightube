search() {
    local query="$1"
    local target="${RESULTS:-5}"
    local fetch_limit="$target"
    local DELIM=$'\t'
    local -a uniq_results batch
    local -A seen_ids
    local iter=0
    local max_iterations=5

    while (( ${#uniq_results[@]} < target && iter < max_iterations )); do
        ((iter++))

        # Fetch up to fetch_limit candidates; include video ID for de-duplication
        mapfile -t batch < <(
            yt-dlp "ytsearch${fetch_limit}:${query}" \
                --print "%(id)s${DELIM}%(title)s${DELIM}%(webpage_url)s${DELIM}%(uploader)s${DELIM}%(view_count)s${DELIM}%(like_count)s${DELIM}%(comment_count)s${DELIM}%(duration_string)s" \
                --no-warnings \
                --ignore-errors 2>/dev/null
        )

        for line in "${batch[@]}"; do
            # Skip empty lines
            [ -z "$line" ] && continue

            IFS=$'\t' read -r vid_id title url uploader views likes comments duration <<< "$line"

            # Require at least an ID and URL to consider it valid
            if [ -z "$vid_id" ] || [ -z "$url" ]; then
                continue
            fi

            # Skip duplicates by video ID
            if [[ -n "${seen_ids[$vid_id]}" ]]; then
                continue
            fi

            seen_ids["$vid_id"]=1

            uniq_results+=("${title}${DELIM}${url}${DELIM}${uploader}${DELIM}${views}${DELIM}${likes}${DELIM}${comments}${DELIM}${duration}")

            # Stop early if we've reached the target
            if (( ${#uniq_results[@]} >= target )); then
                break
            fi
        done

        # Increase fetch limit to pull in more candidates next loop
        ((fetch_limit += target))
    done

    # Output exactly target results if possible, otherwise as many as we have
    local count=${#uniq_results[@]}
    local to_print=$target
    if (( count < target )); then
        to_print=$count
    fi

    local i
    for (( i=0; i<to_print; i++ )); do
        printf '%s\n' "${uniq_results[i]}"
    done
}