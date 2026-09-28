{ userName, ... }:
{
  imports = [
    ./dms.nix
    ./fish.nix
    ./kitty.nix
    ./niri.nix
    ./rime.nix
  ];

  home.username = userName;
  home.homeDirectory = "/home/${userName}";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
