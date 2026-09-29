{ userName, ... }:
{
  imports = [
    ./dms.nix
    ./fish.nix
    ./ghostty.nix
    ./niri.nix
    ./rime.nix
  ];

  home.username = userName;
  home.homeDirectory = "/home/${userName}";
  home.stateVersion = "26.05";

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  };

  programs.home-manager.enable = true;
}
