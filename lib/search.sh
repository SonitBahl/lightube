search() {
    local query="$1"
    local target="${RESULTS:-5}"
    local fetch_limit="$target"
    local DELIM=$'\t'
    local -a uniq_results=()
    local -a batch=()
    local -A seen_ids=()
    local iter=0
    local max_iterations=5

    while (( ${#uniq_results[@]} < target && iter < max_iterations )); do
        ((++iter))

        # Fetch up to fetch_limit candidates; include video ID for de-duplication
        mapfile -t batch < <(
            yt-dlp "ytsearch${fetch_limit}:${query}" \
                --replace-in-metadata "description" "[\r\n\t]" " " \
                --print "%(id)s${DELIM}%(title)s${DELIM}%(webpage_url)s${DELIM}%(uploader)s${DELIM}%(channel_follower_count)s${DELIM}%(view_count)s${DELIM}%(like_count)s${DELIM}%(comment_count)s${DELIM}%(duration_string)s${DELIM}%(channel_url)s${DELIM}%(description)s${DELIM}%(tags)s" \
                --no-warnings \
                --ignore-errors 2>/dev/null || true
        )

        for line in "${batch[@]}"; do
            # Skip empty lines
            [ -z "$line" ] && continue

            IFS=$'\t' read -r vid_id title url uploader subs views likes comments duration channel_url description tags <<< "$line"

            # Require at least an ID and URL to consider it valid
            if [ -z "$vid_id" ] || [ -z "$url" ]; then
                continue
            fi

            # Skip duplicates by video ID
            if [[ -n "${seen_ids[$vid_id]-}" ]]; then
                continue
            fi

            seen_ids["$vid_id"]=1

            # Clean up fields that may contain newlines/tabs to keep TSV stable for fzf
            description=${description//$'\t'/ }
            description=${description//$'\r'/}
            description=${description//$'\n'/ }
            tags=${tags//$'\t'/ }
            tags=${tags//$'\r'/}
            tags=${tags//$'\n'/ }

            # Create a short description snippet for preview
            local desc_short="$description"
            if [ ${#desc_short} -gt 240 ]; then
                desc_short="${desc_short:0:237}..."
            fi

            uniq_results+=("${title}${DELIM}${url}${DELIM}${uploader}${DELIM}${subs}${DELIM}${views}${DELIM}${likes}${DELIM}${comments}${DELIM}${duration}${DELIM}${channel_url}${DELIM}${desc_short}${DELIM}${tags}")

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