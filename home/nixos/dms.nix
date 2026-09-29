{ dmsPackage, coreutils, sed, sudo, ... }:
{
  xdg.configFile."environment.d/90-dms.conf".text = ''
    LANG=zh_CN.UTF-8
    TERMINAL=ghostty
    QT_QPA_PLATFORM=wayland
    QT_QPA_PLATFORMTHEME=gtk3
    QT_QPA_PLATFORMTHEME_QT6=gtk3
    ELECTRON_OZONE_PLATFORM_HINT=auto
  '';

  # Runs as this user during every `nrs` switch (home-manager activates under
  # the target user), so failures abort the rebuild instead of hiding in a
  # login-time service. First switch migrates from home-manager symlinks,
  # then DMS owns niri/ghostty config from then on.
  home.activation.dmsSetup = ''
    export PATH=${coreutils}/bin:${sudo}/bin:$PATH
    dms=${dmsPackage}/bin/dms
    config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}"
    [ -L "$config_dir/niri/config.kdl" ] && rm -f "$config_dir/niri/config.kdl"
    [ -L "$config_dir/ghostty/config" ] && rm -f "$config_dir/ghostty/config"
    if [ ! -f "$config_dir/niri/config.kdl" ]; then
      "$dms" setup headless --compositor niri --terminal ghostty --force </dev/null
    fi
    # DMS's bundled ghostty config still sets background-blur-radius, an
    # option removed from current ghostty; strip it so the terminal starts.
    [ -f "$config_dir/ghostty/config" ] && \
      sed -i '/^background-blur-radius/d' "$config_dir/ghostty/config"
  '';
}
