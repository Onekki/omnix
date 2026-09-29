{ lib, pkgs, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "vscode" ];

  environment.systemPackages = with pkgs; [
    firefox
    git
    ghostty
    nautilus
    papirus-icon-theme
    vscode
    wl-clipboard
  ];
}
