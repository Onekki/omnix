{ dmsPackage, coreutils, foot, sudo, ... }:
{
  xdg.configFile."environment.d/90-dms.conf".text = ''
    LANG=zh_CN.UTF-8
    TERMINAL=foot
    QT_QPA_PLATFORM=wayland
    QT_QPA_PLATFORMTHEME=gtk3
    QT_QPA_PLATFORMTHEME_QT6=gtk3
    ELECTRON_OZONE_PLATFORM_HINT=auto
  '';

  # Runs as this user during every `nrs` switch (home-manager activates under
  # the target user), so failures abort the rebuild instead of hiding in a
  # login-time service. First switch migrates from home-manager symlinks,
  # then DMS owns niri config from then on.
  home.activation.dmsSetup = ''
    export PATH=${coreutils}/bin:${foot}/bin:${sudo}/bin:$PATH
    dms=${dmsPackage}/bin/dms
    config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}"
    [ -L "$config_dir/niri/config.kdl" ] && rm -f "$config_dir/niri/config.kdl"
    if [ ! -f "$config_dir/niri/config.kdl" ]; then
      "$dms" setup headless --compositor niri --force </dev/null
    fi
    [ -f "$config_dir/niri/dms/binds.kdl" ] || "$dms" setup binds </dev/null
  '';
}
