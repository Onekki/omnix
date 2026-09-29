{ userName, ... }:
{
  programs.foot = {
    enable = true;
    settings.main = {
      # DMS writes ~/.config/foot/dank-colors.ini on theme/wallpaper switches.
      include = "/home/${userName}/.config/foot/dank-colors.ini";
      font = "Noto Sans Mono CJK SC:size=11";
    };
  };
}
