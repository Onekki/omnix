{ pkgs, ... }:
{
  programs.dank-material-shell.plugins.wallpaperBing.enable = true;
  # Enable the plugin and "Synchronize terminal fonts" in DMS Settings.
  # NixOS installs plugin sources; DMS keeps the user's settings writable.
  programs.dank-material-shell.plugins.dmsThemeSync.enable = true;

  # Runtime dependencies declared by DMS plugins. On NixOS the systemd user
  # manager PATH doesn't include /run/current-system/sw/bin, so plugin
  # processes need an explicit default PATH as well.
  environment.systemPackages = with pkgs; [
    bash
    coreutils
    curl
    dbus
    findutils
    fontconfig
    gawk
    glib
    gnugrep
    gnused
    inotify-tools
    which
  ];

  # DMS's default monoFontFamily is Fira Code. Make it available to apps too.
  fonts.packages = [ pkgs.fira-code ];

  systemd.user.settings.Manager = {
    DefaultEnvironment = "PATH=/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin";
  };
}
