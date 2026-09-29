{ config, dmsPackage, ... }:
{
  # Runs as this user during every `nrs` switch (home-manager activates under
  # the target user), so failures abort the rebuild instead of hiding in a
  # login-time service. First switch migrates from home-manager symlinks,
  # then DMS owns niri/ghostty config from then on.
  home.activation.dmsSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=${pkgs.coreutils}/bin:${pkgs.sudo}/bin:$PATH
    dms=${dmsPackage}/bin/dms
    config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}"
    [ -L "$config_dir/niri/config.kdl" ] && rm -f "$config_dir/niri/config.kdl"
    [ -L "$config_dir/ghostty/config" ] && rm -f "$config_dir/ghostty/config"
    if [ ! -f "$config_dir/niri/config.kdl" ]; then
      "$dms" setup headless --compositor niri --terminal ghostty --force </dev/null
    fi
  '';
}
