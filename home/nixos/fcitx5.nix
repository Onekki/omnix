{ ... }:
{
  # Replaces the bundled fcitx5-rime tray icons with clean vector variants.
  xdg.dataFile = {
    "icons/hicolor/scalable/apps/fcitx-rime.svg".source =
      ../../assets/fcitx5-icons/fcitx-rime.svg;
    "icons/hicolor/scalable/apps/fcitx_rime_im.svg".source =
      ../../assets/fcitx5-icons/fcitx_rime_im.svg;
    "icons/hicolor/scalable/apps/fcitx_rime_latin.svg".source =
      ../../assets/fcitx5-icons/fcitx_rime_latin.svg;
  };
}
