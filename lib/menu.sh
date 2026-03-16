show_menu() {

fzf \
  --delimiter=$'\t' \
  --with-nth=1 \
  --height=90% \
  --layout=reverse \
  --border \
  --preview-window=right:50%,border \
  --preview '
human() {
  local n="$1"
  n="${n//,/}"
  if [ -z "$n" ] || ! [[ "$n" =~ ^[0-9]+$ ]]; then
    printf "%s" "n/a"
    return
  fi
  if [ "$n" -ge 1000000000 ]; then
    awk -v v="$n" '\''BEGIN { printf "%.1fB", v/1000000000 }'\'' | sed "s/\\.0B$/B/"
  elif [ "$n" -ge 1000000 ]; then
    awk -v v="$n" '\''BEGIN { printf "%.1fM", v/1000000 }'\'' | sed "s/\\.0M$/M/"
  elif [ "$n" -ge 1000 ]; then
    awk -v v="$n" '\''BEGIN { printf "%.1fK", v/1000 }'\'' | sed "s/\\.0K$/K/"
  else
    printf "%s" "$n"
  fi
}

printf "Channel     : %s\n" {3}
printf "Subscribers : %s\n" "$(human {4})"
printf "Views       : %s\n" "$(human {5})"
printf "Likes       : %s\n" "$(human {6})"
printf "Comments    : %s\n" "$(human {7})"
printf "Duration    : %s\n" {8}
echo ""
printf "%s\n" {10} | fold -s -w 60
' \
  --prompt="Select video > "

}