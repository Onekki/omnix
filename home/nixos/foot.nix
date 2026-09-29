{ config, ... }:
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        # DMS owns this palette and regenerates it on theme/wallpaper changes.
        include = "${config.xdg.configHome}/foot/dank-colors.ini";
        # Match DMS's default mono family; install fonts in the desktop module.
        font = "Fira Code:size=12,Noto Sans Mono CJK SC:size=12";
        dpi-aware = "no";
        pad = "12x12";
      };
      cursor = {
        style = "beam";
        blink = "yes";
      };
      mouse.hide-when-typing = "yes";
    };
  };
}
