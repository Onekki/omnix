{ shell, ... }:
let
  implementations = {
    dms = ./dms.nix;
    noctalia = ./noctalia.nix;
  };
in
{
  # One choice controls the desktop service and its matching login greeter.
  imports = [ implementations.${shell} ];
}
