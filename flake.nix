{
  description = "NixOS desktop: Niri, DMS or Noctalia, and Rime";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dankcalendar = {
      url = "github:AvengeMedia/dankcalendar";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, home-manager, ... }:
    let
      userName = "admin";
      hostName = "nixos";
      system = "x86_64-linux";
      mkDesktop = { shell, inputMethod ? "fcitx5" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs userName shell inputMethod; };
          modules = [
            ./hosts/desktop
            home-manager.nixosModules.home-manager
            ({ pkgs, ... }: {
              networking.hostName = hostName;
              users.users.${userName} = {
                isNormalUser = true;
                extraGroups = [ "wheel" "networkmanager" "video" "input" ];
                shell = pkgs.fish;
              };
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-backup";
                extraSpecialArgs = {
                  inherit inputs userName shell inputMethod;
                  configurationName = "desktop-${shell}";
                };
                users.${userName} = import ./home/nixos;
              };
            })
          ];
        };
    in {
      nixosConfigurations = rec {
        desktop-dms = mkDesktop { shell = "dms"; };
        desktop-noctalia = mkDesktop { shell = "noctalia"; };
        # Preserve the original installation/rebuild target.
        desktop = desktop-dms;
      };
    };
}
