{ lib, pkgs, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "microsoft-edge" "vscode" ];

  environment.systemPackages = with pkgs; [
    git
    kitty
    microsoft-edge
    nautilus
    papirus-icon-theme
    vscode
    wl-clipboard
  ];
}
