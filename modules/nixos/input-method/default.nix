{ inputMethod, ... }:
let
  implementations = {
    fcitx5 = ./fcitx5.nix;
  };
in
{
  imports = [ implementations.${inputMethod} ];
}
