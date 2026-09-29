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
  # login-time service. Idempotent: both subcommands skip existing output.
  home.activation.dmsSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    export DMS_BIN=${lib.getExe dmsPackage}
    export PATH=${lib.makeBinPath [ pkgs.bash pkgs.coreutils pkgs.sudo ]}:$PATH
    bash ${../../scripts/dms.sh} setup
  '';
}
