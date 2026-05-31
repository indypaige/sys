{
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url      = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, home-manager, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
        build = host:
          { extraSpecialArgs ? []
          , wallpaper        ? []
          , extraEnv         ? {}
          , modules          ? []
          , inputs
          , output
          , email
          , home
          , ssh
          }@builder: let
            env  = extraEnv // builder;
            home = {
              home-manager.extraSpecialArgs = extraSpecialArgs // {
                inherit env;

                inputs = map (x: x.packages.${system}.default) inputs;
              };

              home-manager.useUserPackages  = true;
              home-manager.users.${host}    = home;
              home-manager.useGlobalPkgs    = true;
            };
          in {
            nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
              inherit system;

              modules = modules ++ [
                home-manager.nixosModules.home-manager
                home
              ];
            };
          };
      }); }
