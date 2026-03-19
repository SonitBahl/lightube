## Lightube

Terminal YouTube player/search UI using `yt-dlp`, `fzf`, and `mpv`.

### Install (Linux)

From the project folder:

```bash
chmod +x ./install.sh
./install.sh
```

This creates a symlink at `/usr/local/bin/lightube`, so you can run `lightube` from anywhere.

### Usage

```bash
lightube
lightube help
lightube edit
lightube config
lightube reset
```

### Configuration

Config file:

`$HOME/.config/lightube.conf`

Defaults:

```bash
RESULTS=5
MAX_RESOLUTION=1080
PLAYER=mpv
```

### Dependencies

- `yt-dlp`
- `fzf`
- `mpv` (or another player via `PLAYER=...`)
- `xdg-open`
- `less`

# Author

Sonit Bahl
