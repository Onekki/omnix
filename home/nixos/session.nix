{ ... }:
{
  xdg.configFile."environment.d/90-desktop.conf".text = ''
    LANG=zh_CN.UTF-8
    TERMINAL=foot
    QT_QPA_PLATFORM=wayland
    QT_QPA_PLATFORMTHEME=gtk3
    QT_QPA_PLATFORMTHEME_QT6=gtk3
    ELECTRON_OZONE_PLATFORM_HINT=auto
  '';
}
