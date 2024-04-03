{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "parts";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.parts.lib.mkFlake
    { inherit inputs; }
    {
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      imports = [ inputs.ez-configs.flakeModule ];

      ezConfigs = {
        root = ./.;
        globalArgs = { inherit inputs; };
      };

      perSystem = { pkgs, lib, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.sops-nix.overlays.default ];
        };

        devShells.default = pkgs.mkShell {
          name = "nix-mc-shell";
          packages = lib.attrValues {
            inherit (pkgs)
              nixos-rebuild
              sops
              packwiz
              ;
          };
        };
      };
    };
}
