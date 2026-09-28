{ pkgs, ... }:
let
  yaml = pkgs.formats.yaml { };
in
{
  xdg.dataFile."fcitx5/rime/default.custom.yaml".source = yaml.generate "rime-default-custom.yaml" {
    patch = {
      __include = "rime_ice_suggestion:/";
      schema_list = [ { schema = "rime_ice"; } ];
    };
  };
}
