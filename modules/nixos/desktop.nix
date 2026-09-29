{ config, lib, pkgs, userName, dgop, danksearch, ... }:
let
  dmsNiriSetup = pkgs.writeShellScript "dms-niri-setup" ''
    set -eu
    export PATH=${lib.makeBinPath [ config.programs.niri.package pkgs.kitty ]}
    config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}"

    for fragment in binds colors layout alttab outputs cursor windowrules; do
      if [ ! -e "$config_dir/niri/dms/$fragment.kdl" ]; then
        ${lib.getExe config.programs.dank-material-shell.package} setup "$fragment"
      fi
    done
  '';
in
{
  hardware.graphics.enable = true;

  services.displayManager = {
    defaultSession = "niri";
    dms-greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/${userName}";
      logs = {
        save = true;
        path = "/var/lib/dms-greeter/greeter.log";
      };
    };
  };
  programs.niri.enable = true;
  programs.dconf.enable = true;
  programs.dank-material-shell = {
    enable = true;
    enableDynamicTheming = true;
    systemd.enable = true;
  };
  programs.dsearch = {
    enable = true;
    package = danksearch.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd.target = "graphical-session.target";
  };
  programs.dank-calendar = {
    enable = true;
    systemd.enable = true;
  };

  systemd.user.services.dms-niri-setup = {
    description = "Initialize DMS Niri configuration";
    before = [ "dms.service" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = dmsNiriSetup;
    };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;
  services.upower.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans CJK SC" "Noto Sans" ];
    serif = [ "Noto Serif CJK SC" "Noto Serif" ];
    monospace = [ "Noto Sans Mono CJK SC" "Noto Sans Mono" ];
  };

  environment.systemPackages = with pkgs; [
    adw-gtk3
    qt6Packages.fcitx5-configtool
    firefox
    git
    kitty
    nautilus
    papirus-icon-theme
    wl-clipboard
  ] ++ [ dgop.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
