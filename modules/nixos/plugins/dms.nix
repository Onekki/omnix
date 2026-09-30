{ pkgs, ... }:
{
  programs.dank-material-shell.plugins.wallpaperBing.enable = true;

  # Runtime dependencies declared by DMS plugins.
  environment.systemPackages = with pkgs; [
    curl
    inotify-tools
    which
  ];
}
