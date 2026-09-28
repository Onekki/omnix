{ ... }:
{
  xdg.configFile."environment.d/90-dms.conf".text = ''
    TERMINAL=kitty
    QT_QPA_PLATFORM=wayland
    QT_QPA_PLATFORMTHEME=gtk3
    QT_QPA_PLATFORMTHEME_QT6=gtk3
    ELECTRON_OZONE_PLATFORM_HINT=auto
  '';
}
