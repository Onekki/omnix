{ config, lib, pkgs, userName, dgop, danksearch, ... }:
let
  ghosttyThemeDefault = pkgs.writeText "ghostty-dankcolors"
    (builtins.readFile ../../assets/ghostty/dankcolors);

  dmsNiriSetup = pkgs.writeShellScript "dms-niri-setup" ''
    set -u
    # systemd user services get a minimal PATH on NixOS. DMS setup requires
    # sudo on PATH (its setup commands run a privesc pre-check), plus coreutils.
    export PATH=${lib.makeBinPath [ config.programs.niri.package pkgs.ghostty pkgs.coreutils pkgs.sudo ]}
    config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}"
    dms_dir="$config_dir/niri/dms"
    dms=${lib.getExe config.programs.dank-material-shell.package}
    mkdir -p "$dms_dir"

    # ghostty config declares `theme = dankcolors`, but Matugen only generates
    # that file on the first theme switch. Seed DMS's default palette so the
    # terminal starts before then; Matugen overwrites it on later switches.
    ghostty_theme="$config_dir/ghostty/themes/dankcolors"
    if [ ! -f "$ghostty_theme" ]; then
      install -Dm0644 ${ghosttyThemeDefault} "$ghostty_theme"
      printf 'dms-niri-setup: seeded ghostty dankcolors theme\n' >&2
    fi

    failed=0
    for fragment in binds colors layout alttab input outputs cursor windowrules; do
      [ -s "$dms_dir/$fragment.kdl" ] && continue
      if ! "$dms" setup "$fragment" </dev/null; then
        printf 'dms-niri-setup: ERROR deploying %s\n' "$fragment" >&2
        failed=1
      fi
    done
    exit "$failed"
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
  ] ++ [ dgop.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
