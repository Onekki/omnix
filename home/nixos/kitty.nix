{ config, ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      # Match DMS's terminal defaults; colors and fonts come from its includes.
      window_padding_width = 12;
      hide_window_decorations = "yes";
      tab_bar_style = "powerline";
      tab_bar_align = "left";
    };
    extraConfig = ''
      include ${config.xdg.configHome}/kitty/dank-tabs.conf
      include ${config.xdg.configHome}/kitty/dank-theme.conf
      include ${config.xdg.configHome}/dms-theme-sync/kitty.conf
    '';
  };
}
