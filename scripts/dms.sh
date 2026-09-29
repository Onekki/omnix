#!/usr/bin/env bash
set -u

DMS_BIN=${DMS_BIN:?DMS_BIN not set}
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
niri_config="$config_dir/niri/config.kdl"
ghostty_config="$config_dir/ghostty/config"

# Old home-manager generations left read-only store symlinks for these files;
# DMS owns them now, so remove any symlink before letting DMS write.
if [ -L "$niri_config" ] || [ -L "$ghostty_config" ]; then
  printf 'dms-setup: removing home-manager config symlinks\n' >&2
  rm -f "$niri_config" "$ghostty_config"
fi

# One full default initialization: DMS deploys niri, fragments and ghostty.
if [ ! -f "$niri_config" ]; then
  exec "$DMS_BIN" setup headless --compositor niri --terminal ghostty --force </dev/null
fi
