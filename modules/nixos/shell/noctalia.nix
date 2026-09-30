{ inputs, pkgs, userName, ... }:
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

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
    systemd.enable = true;
  };
  systemd.user.services.noctalia.unitConfig.Conflicts = [ "dms.service" ];
}
