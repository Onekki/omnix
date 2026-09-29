{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/apps.nix
    ../../modules/nixos/plugins.nix
    ../../modules/nixos/input-method.nix
  ];

  system.stateVersion = "26.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.cpu.intel.updateMicrocode = true;
}
