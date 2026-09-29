{ userName, dmsPackage, ... }:
{
  imports = [
    ./dms.nix
    ./fcitx5.nix
    ./fish.nix
    ./foot.nix
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
}
