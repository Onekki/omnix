{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        (fcitx5-rime.override { rimeDataPkgs = [ rime-ice ]; })
      ];
      settings.inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "rime";
        };
        "Groups/0/Items/0" = { Name = "keyboard-us"; Layout = ""; };
        "Groups/0/Items/1" = { Name = "rime"; Layout = ""; };
        GroupOrder = { "0" = "Default"; };
      };
    };
  };
}
