{ dmsPackage, ... }:
{
  # Runs as this user during every `nrs` switch (home-manager activates under
  # the target user), so failures abort the rebuild instead of hiding in a
  # login-time service. First switch migrates from home-manager symlinks,
  # then DMS owns niri/ghostty config from then on.
  home.activation.dmsSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.sudo ]}:$PATH
    dms=${lib.getExe dmsPackage}
    config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}"
    [ -L "$config_dir/niri/config.kdl" ] && rm -f "$config_dir/niri/config.kdl"
    [ -L "$config_dir/ghostty/config" ] && rm -f "$config_dir/ghostty/config"
    if [ ! -f "$config_dir/niri/config.kdl" ]; then
      "$dms" setup headless --compositor niri --terminal ghostty --force </dev/null
    fi
  '';
}
