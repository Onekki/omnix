{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # DMS generates ~/.config/ghostty/themes/dankcolors on theme switch.
      theme = "dankcolors";
      font-family = "Noto Sans Mono CJK SC";
      font-size = 11;
      window-padding-x = 10;
      window-padding-y = 10;
      cursor-style = "beam";
      scrollback-limit = 10000;
    };
  };
}
