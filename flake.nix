{
  description = "NixOS desktop: Niri, DMS and Rime";

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
  };

  outputs =
    { nixpkgs, home-manager, dms, dgop, danksearch, dankcalendar, dms-plugin-registry, ... }:
    let
      userName = "admin";
      hostName = "nixos";
      configurationName = "desktop";
      system = "x86_64-linux";
    in {
      nixosConfigurations.${configurationName} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit userName dgop danksearch; };
        modules = [
          ./hosts/desktop
          dms.nixosModules.default
          dms-plugin-registry.nixosModules.default
          dankcalendar.nixosModules.default
          home-manager.nixosModules.home-manager
          ({ pkgs, config, ... }: {
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
                inherit userName configurationName;
                dmsPackage = config.programs.dank-material-shell.package;
                inherit (pkgs) coreutils sed sudo;
              };
              users.${userName} = import ./home/nixos;
            };
          })
        ];
      };
    };
}
