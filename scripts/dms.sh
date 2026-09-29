#!/usr/bin/env bash
set -u

DMS_BIN=${DMS_BIN:?DMS_BIN not set}
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}

setup_niri() {
  dms_dir="$config_dir/niri/dms"
  mkdir -p "$dms_dir"

  failed=0
  for fragment in binds colors layout alttab input outputs cursor windowrules; do
    [ -s "$dms_dir/$fragment.kdl" ] && continue
    if ! "$DMS_BIN" setup "$fragment" </dev/null; then
      printf 'dms-niri-setup: ERROR deploying %s\n' "$fragment" >&2
      failed=1
    fi
  done
  exit "$failed"
}

bootstrap_theme() {
  cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
  ghostty_theme="$config_dir/ghostty/themes/dankcolors"
  [ -f "$ghostty_theme" ] && exit 0

  wp=$(jq -r '(.wallpaperPath // .session.wallpaperPath // .settings.wallpaperPath // "") | sub("^file://"; "")' \
    "$config_dir/DankMaterialShell/settings.json" 2>/dev/null || true)
  [ -n "$wp" ] && [ -f "$wp" ] || exit 0

  shell_dir="$(dirname "$(dirname "$DMS_BIN")")/share/quickshell/dms"
  exec "$DMS_BIN" matugen generate --state-dir "$cache_dir/DankMaterialShell" \
    --shell-dir "$shell_dir" --config-dir "$config_dir" \
    --kind image --value "$wp" --mode dark </dev/null >/dev/null 2>&1
}

case "${1:-}" in
  niri-setup)
    setup_niri
    ;;
  theme-bootstrap)
    bootstrap_theme
    ;;
  *)
    printf 'usage: %s niri-setup|theme-bootstrap\n' "$0" >&2
    exit 2
    ;;
esac
