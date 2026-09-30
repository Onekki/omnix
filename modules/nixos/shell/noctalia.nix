{ config, inputs, lib, pkgs, userName, ... }:
let
  greeter = config.services.displayManager.noctalia-greeter;
in
{
  imports = [ inputs.noctalia.nixosModules.default ];

  environment.sessionVariables.NIRI_CONFIG = "/home/${userName}/.config/niri/noctalia-session.kdl";

  services.displayManager.noctalia-greeter = {
    enable = true;
    # VirtualBox VMSVGA: fix vmwgfx DMA-BUF handle release in this greeter only.
    package = pkgs.noctalia-greeter.override {
      wlroots_0_20 = pkgs.wlroots_0_20.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./patches/wlroots-vmwgfx-handles.patch ];
      });
    };
  };

  # Temporary, explicitly enabled VirtualBox diagnostic. Remove this command
  # override to restore the upstream renderer selection after the test.
  # greetd starts the authenticated desktop separately from this process.
  services.greetd.settings.default_session.command = lib.escapeShellArgs (
    [
      "${pkgs.coreutils}/bin/env"
      "WLR_RENDERER=pixman"
      "LIBGL_ALWAYS_SOFTWARE=1"
      "WLR_LOG=info"
      (lib.getExe' greeter.package "noctalia-greeter-session")
    ] ++ greeter.extraArgs
  );

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
    systemd.enable = true;
  };
  systemd.user.services.noctalia.unitConfig.Conflicts = [ "dms.service" ];
}
