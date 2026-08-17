{
  description = "My Nix environment";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://chaotic-nyx.cachix.org"
    ];
    extra-trusted-public-keys = [
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
    ];
  };
  inputs = {
    # TODO: revert to NixOS/nixos-hardware/master once PR #1912 (Dell XPS 14
    # DA14260 / Panther Lake) is merged.
    nixos-hardware.url = "github:cooparo/nixos-hardware/dell-xps-14-da14260";
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    catppuccin.url = "github:catppuccin/nix";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nur.url = "github:nix-community/nur";
    intel-lpmd-flake = {
      url = "github:dmfrpro/intel-lpmd-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixos,
      nixpkgs,
      home-manager,
      nix-darwin,
      nixvim,
      vscode-server,
      nur,
      catppuccin,
      nixos-hardware,
      ...
    }@inputs:
    let
      nixpkgsConfig = {
        allowUnfree = true;
        permittedInsecurePackages = [ "electron-40.10.5" ];
      };
      pkgsX86 = import nixpkgs {
        system = "x86_64-linux";
        config = nixpkgsConfig;
      };
      pkgsArm = import nixpkgs {
        system = "aarch64-darwin";
        config = nixpkgsConfig;
      };
      chaoticModule = {
        chaotic.nyx.overlay.enable = false;
        nixpkgs.overlays = [
          (import "${inputs.chaotic}/overlays/cache-friendly.nix" {
            flakes = {
              inherit (inputs.chaotic.inputs) nixpkgs;
              self = inputs.chaotic;
            };
            inherit nixpkgsConfig;
          })
        ];
      };

      # Import shells function properly
      importShells = pkgs: import ./shells.nix pkgs;
      hosts = [
        "pittsburgh"
        "madison"
        "octal"
        "ruby"
        "nixnas"
      ];
      mkSystem =
        modules:
        nixos.lib.nixosSystem {
          modules = [
            { nixpkgs.config = nixpkgsConfig; }
            chaoticModule
            nur.modules.nixos.default
            vscode-server.nixosModules.default
            inputs.chaotic.nixosModules.default
          ]
          ++ modules;
          specialArgs = { inherit inputs; };
        };
      mkHost = host: {
        ${host} = mkSystem [ ./hosts/${host} ];
      };

      accounts = [
        "aoli@octal"
        "aoli@ruby"
        "aoli@arrakis"
        "hao@linux"
        "hao@nixnas"
      ];
      headlessHosts = [
        "arrakis"
      ];
      mkAccount =
        account:
        let
          parts = nixpkgs.lib.splitString "@" account;
          user = builtins.elemAt parts 0;
          host = builtins.elemAt parts 1;
          pkgs = pkgsX86;
          isHeadless = builtins.elem host headlessHosts;
        in
        {
          "${account}" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              (./programs/accounts + "/${user}.nix")
              (./programs/hosts + "/${host}.nix")
            ]
            ++ nixpkgs.lib.optionals (!isHeadless) [
              ./programs/niri
            ]
            ++ [
              ./home.nix
              nixvim.homeModules.nixvim
              catppuccin.homeModules.catppuccin
            ];
            extraSpecialArgs = {
              inherit inputs isHeadless;
              isLinux = pkgs.stdenv.isLinux;
            };
          };
        };
    in
    {
      packages = home-manager.packages;

      nixosConfigurations = nixos.lib.mergeAttrsList (map mkHost hosts);

      darwinConfigurations."Aos-MacBook-Air" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          { nixpkgs.config = nixpkgsConfig; }
          ./hosts/darwin
        ];
        specialArgs = { inherit inputs; };
      };

      homeConfigurations = nixpkgs.lib.mergeAttrsList (map mkAccount accounts) // {
        "aoli@darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsArm;
          modules = [
            ./programs/accounts/aoli.nix
            ./home.nix
            nixvim.homeModules.nixvim
            catppuccin.homeModules.catppuccin
          ];
          extraSpecialArgs = {
            inherit inputs;
            isLinux = false;
            isHeadless = false;
          };
        };
      };

      # Properly structure devShells
      devShells = {
        "x86_64-linux" = importShells pkgsX86;
        "aarch64-darwin" = importShells pkgsArm;
      };
    };
}
