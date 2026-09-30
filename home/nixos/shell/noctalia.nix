{ config, inputs, osConfig, ... }:
let
  noctaliaPackage = osConfig.programs.noctalia.package;
in
{
  imports = [ inputs.noctalia.homeModules.default ../niri/noctalia.nix ];

  programs.foot.settings.main.include = "${config.xdg.configHome}/foot/themes/noctalia";

  # The NixOS module owns the service. The official Home Manager module owns
  # base settings; Noctalia saves GUI overrides separately in its state folder.
  programs.noctalia = {
    enable = true;
    package = noctaliaPackage;
    settings = {
      shell.launch_apps_as_systemd_services = true;
      # Use the shipped template without its config-editing hook: foot.ini is
      # declarative, and already includes this output in the Noctalia profile.
      theme.templates.user.foot = {
        input_path = "${noctaliaPackage}/share/noctalia/assets/templates/foot/foot";
        output_path = "${config.xdg.configHome}/foot/themes/noctalia";
      };
    };
  };
}
