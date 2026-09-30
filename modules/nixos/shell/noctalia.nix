{ inputs, userName, ... }:
{
  imports = [ inputs.noctalia.nixosModules.default ];

  environment.sessionVariables.NIRI_CONFIG = "/home/${userName}/.config/niri/noctalia-session.kdl";

  services.displayManager.noctalia-greeter.enable = true;

  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
    systemd.enable = true;
  };
  systemd.user.services.noctalia.unitConfig.Conflicts = [ "dms.service" ];
}
