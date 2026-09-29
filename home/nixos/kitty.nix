{ ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "monospace";
      font_size = 11;
      window_padding_width = 10;
      scrollback_lines = 10000;
      cursor_shape = "beam";
    };
    extraConfig = ''
      include dank-tabs.conf
      include dank-theme.conf
    '';
  };
}
