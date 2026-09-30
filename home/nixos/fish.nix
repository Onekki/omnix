{ config, configurationName, ... }:
let
  rebuild = profile: "sudo nixos-rebuild switch --flake \"path:${config.home.homeDirectory}/.nixos#${profile}\"";
in
{
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -lah";
      la = "ls -A";
      nrs = rebuild configurationName;
      nrsd = rebuild "desktop-dms";
      nrsn = rebuild "desktop-noctalia";
    };
    interactiveShellInit = ''
      set -g fish_greeting ""
    '';
  };
}
