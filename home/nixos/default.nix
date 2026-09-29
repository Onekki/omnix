{ userName, dmsPackage, ... }:
{
  imports = [
    ./dms.nix
    ./fcitx5.nix
    ./fish.nix
    ./rime.nix
  ];

  home.username = userName;
  home.homeDirectory = "/home/${userName}";
  home.stateVersion = "26.05";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "microsoft-edge.desktop";
      "application/xhtml+xml" = "microsoft-edge.desktop";
      "x-scheme-handler/http" = "microsoft-edge.desktop";
      "x-scheme-handler/https" = "microsoft-edge.desktop";
    };
  };

  programs.home-manager.enable = true;

  # Runs as this user during every `nrs` switch (home-manager activates under
  # the target user), so failures abort the rebuild instead of hiding in a
  # login-time service. First switch migrates from home-manager symlinks,
  # then DMS owns niri/ghostty config from then on.
  home.activation.dmsSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
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
