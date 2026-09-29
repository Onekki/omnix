{ config, lib, pkgs, userName, dgop, danksearch, ... }:
let
  dmsNiriSetup = pkgs.writeShellScript "dms-niri-setup" ''
    set -u
    export PATH=${lib.makeBinPath [ config.programs.niri.package pkgs.kitty ]}
    config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}"
    dms_dir="$config_dir/niri/dms"
    dms=${lib.getExe config.programs.dank-material-shell.package}
    log="$config_dir/dms-niri-setup.log"
    mkdir -p "$dms_dir"

    failed=0

    deploy_fragment() {
      fragment=$1
      file="$dms_dir/$fragment.kdl"

      # Regenerate empty placeholders too: DMS writes empty outputs/cursor/windowrules.
      if [ -s "$file" ]; then
        printf 'dms-niri-setup: %s already present, skipping\n' "$fragment" >>"$log"
        return 0
      fi
      if "$dms" setup "$fragment" </dev/null >>"$log" 2>&1; then
        printf 'dms-niri-setup: deployed %s\n' "$fragment" >>"$log"
      else
        printf 'dms-niri-setup: ERROR: failed to deploy %s\n' "$fragment" >>"$log"
        printf 'dms-niri-setup: ERROR: failed to deploy %s\n' "$fragment" >&2
        failed=1
      fi
    }

    # Deploy each fragment independently so one failure cannot hide the others,
    # then exit non-zero so the unit shows as failed and the problem stays visible.
    deploy_fragment binds
    deploy_fragment colors
    deploy_fragment layout
    deploy_fragment alttab
    deploy_fragment input
    deploy_fragment outputs
    deploy_fragment cursor
    deploy_fragment windowrules

    if [ "$failed" -ne 0 ]; then
      printf 'dms-niri-setup: one or more fragments failed, see %s\n' "$log" >&2
      exit 1
    fi
  '';
in
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "vscode" ];

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
    firefox
    git
    kitty
    nautilus
    papirus-icon-theme
    vscode
    wl-clipboard
  ] ++ [ dgop.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
