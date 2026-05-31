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
          , packages         ? []
          , modules          ? []
          , output
          , email
          , user
          , home
          , ssh
          }@builder: let
            env  = extraEnv // builder;
            hm   = {
              home-manager.extraSpecialArgs = extraSpecialArgs // {
                inherit env;

                packages = map (x: x.packages.${system}.default) packages;
              };

              home-manager.useUserPackages  = true;
              home-manager.users.${user}    = home;
              home-manager.useGlobalPkgs    = true;
            };
          in {
            nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
              inherit system;

              modules = modules ++ [
                home-manager.nixosModules.home-manager
                hm
              ];
            };
          };
    });
}
