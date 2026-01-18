{
  description = "My Nix environment";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
    ];
  };
  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
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
      inputs.quickshell.follows = "quickshell"; # Use same quickshell version
    };
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nur.url = "github:nix-community/nur";
    starship-jj = {
      url = "gitlab:lanastara_foss/starship-jj";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixos,
      nixpkgs,
      home-manager,
      nixvim,
      vscode-server,
      nur,
      catppuccin,
      niri,
      nixos-hardware,
      starship-jj,
      ...
    }@inputs:
    let
      pkgsX86 = import nixpkgs {
        system = "x86_64-linux";
      };
      pkgsArm = import nixpkgs {
        system = "aarch64-darwin";
      };

      # Import shells function properly
      importShells = pkgs: import ./shells.nix pkgs;
      hosts = [
        "pittsburgh"
        "madison"
        "octal"
        "ruby"
        "jex"
      ];
      mkHost = host: {
        ${host} = nixos.lib.nixosSystem {
          modules = [
            nur.modules.nixos.default
            vscode-server.nixosModules.default
            ./hosts/${host}
          ]
          ++ (if host == "jex" then [ nixos-hardware.nixosModules.dell-xps-13-9315 ] else [ ]);
          specialArgs = { inherit inputs; };
        };
      };

      accounts = [
        "aoli@ruby"
        "aoli@octal"
        "aoli@jex"
        "hao@linux"
      ];
      mkAccount =
        account:
        let
          parts = nixpkgs.lib.splitString "@" account;
          user = builtins.elemAt parts 0;
          host = builtins.elemAt parts 1;
        in
        {
          "${account}" = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgsX86;
            modules = [
              (./programs/accounts + "/${user}.nix")
              (./programs/hosts + "/${host}.nix")
              niri.homeModules.niri
              ./programs/niri
              ./home.nix
              nixvim.homeModules.nixvim
              catppuccin.homeModules.catppuccin
            ];
            extraSpecialArgs = {
              inherit inputs;
              isLinux = pkgsX86.stdenv.isLinux;
              starship-jj = starship-jj.packages.x86_64-linux.default;
            };
          };
        };
    in
    {
      packages = home-manager.packages;

      nixosConfigurations = nixos.lib.mergeAttrsList (map mkHost hosts);
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
            starship-jj = starship-jj.packages.aarch64-darwin.default;
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
