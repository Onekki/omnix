{ config, configurationName, ... }:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -lah";
      la = "ls -A";
      nrs = "sudo nixos-rebuild switch --flake \"path:${config.home.homeDirectory}/.nixos#${configurationName}\"";
    };
    interactiveShellInit = ''
      set -g fish_greeting ""
    '';
  };
}
