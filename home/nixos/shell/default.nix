{ shell, ... }:
let
  implementations = {
    dms = ./dms.nix;
    noctalia = ./noctalia.nix;
  };
in
{
  imports = [ implementations.${shell} ];
}
