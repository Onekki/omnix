{ ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocales = [ "en_US.UTF-8/UTF-8" ];
  console.keyMap = "us";
  programs.fish.enable = true;

  networking.networkmanager.enable = true;
  services.fwupd.enable = true;
  services.udisks2.enable = true;
  hardware.enableRedistributableFirmware = true;
}
