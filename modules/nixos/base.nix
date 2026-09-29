{ ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://cache.nixos.org/"
  ];

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocales = [ "zh_CN.UTF-8/UTF-8" ];
  console.keyMap = "us";
  programs.fish.enable = true;

  networking.networkmanager.enable = true;
  services.fwupd.enable = true;
  services.udisks2.enable = true;
  hardware.enableRedistributableFirmware = true;
}
