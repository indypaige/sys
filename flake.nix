{
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url      = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, home-manager, ... }: {
    mk = host:
      { extraSpecialArgs ? {}
      , wallpaper        ? []
      , extraEnv         ? {}
      , packages         ? []
      , modules          ? []
      , system           ? "x86_64-linux"
      , output
      , email
      , user
      , home
      , ssh
      }@builder: let
        env  = extraEnv // builder;
        hm   = {
          home-manager.extraSpecialArgs = extraSpecialArgs // { inherit env; };

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
  };
}
