{ pkgs, ... }:
{
  programs.dank-material-shell.plugins.wallpaperBing.enable = true;

  # Runtime dependencies declared by DMS plugins. On NixOS the systemd user
  # manager PATH doesn't include /run/current-system/sw/bin, so plugin
  # processes need an explicit default PATH as well.
  environment.systemPackages = with pkgs; [
    curl
    inotify-tools
    which
  ];

  systemd.user.settings.Manager = {
    DefaultEnvironment = "PATH=/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin";
  };
}
