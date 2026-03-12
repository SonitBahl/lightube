show_menu() {

fzf \
  --delimiter=$'\t' \
  --with-nth=1 \
  --height=90% \
  --layout=reverse \
  --border \
  --preview-window=right:50%,border \
  --preview '
echo "Channel : {3}"
echo "Views   : {4}"
echo "Likes   : {5}"
echo "Comments: {6}"
echo "Duration: {7}"
' \
  --prompt="Select video > "

}