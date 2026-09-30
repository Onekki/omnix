{ pkgs, inputs, userName, ... }:
{
  imports = [
    inputs.dms.nixosModules.default
    inputs.dms-plugin-registry.nixosModules.default
    inputs.dankcalendar.nixosModules.default
    ../plugins/dms.nix
  ];

  environment.sessionVariables.NIRI_CONFIG = "/home/${userName}/.config/niri/config.kdl";

  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    configHome = "/home/${userName}";
    logs = {
      save = true;
      path = "/var/lib/dms-greeter/greeter.log";
    };
  };

  programs.dank-material-shell = {
    enable = true;
    enableDynamicTheming = true;
    systemd.enable = true;
  };
  systemd.user.services.dms.unitConfig.Conflicts = [ "noctalia.service" ];

  programs.dsearch = {
    enable = true;
    package = inputs.danksearch.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd.target = "graphical-session.target";
  };
  programs.dank-calendar = {
    enable = true;
    systemd.enable = true;
  };
  environment.systemPackages = [ inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
