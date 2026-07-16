{
  description = "My Nix environment";
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
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
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
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
      nix-darwin,
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
      pkgsArmLinux = import nixpkgs {
        system = "aarch64-linux";
        config = nixpkgsConfig;
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
            nur.modules.nixos.default
            vscode-server.nixosModules.default
          ]
          ++ modules;
          specialArgs = { inherit inputs; };
        };
      mkHost = host: {
        ${host} = mkSystem [ ./hosts/${host} ];
      };

      mkJexSystem =
        modules:
        inputs.nixos-raspberrypi.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            { nixpkgs.config = nixpkgsConfig; }
            nur.modules.nixos.default
            vscode-server.nixosModules.default
            ./hosts/jex
          ]
          ++ modules;
        };

      accounts = [
        "aoli@octal"
        "aoli@ruby"
        "aoli@jex"
        "hao@linux"
        "hao@nixnas"
      ];
      hostSystems = {
        jex = "aarch64-linux";
      };
      headlessHosts = [ "jex" ];
      pkgsFor = {
        "x86_64-linux" = pkgsX86;
        "aarch64-linux" = pkgsArmLinux;
      };
      mkAccount =
        account:
        let
          parts = nixpkgs.lib.splitString "@" account;
          user = builtins.elemAt parts 0;
          host = builtins.elemAt parts 1;
          system = hostSystems.${host} or "x86_64-linux";
          pkgs = pkgsFor.${system};
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
              niri.homeModules.niri
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
              starship-jj = starship-jj.packages.${system}.default;
            };
          };
        };
    in
    {
      packages = home-manager.packages;

      nixosConfigurations = nixos.lib.mergeAttrsList (map mkHost hosts) // {
        jex = mkJexSystem [ ];
      };

      images.jex = (mkJexSystem [ ./hosts/jex/sd-image.nix ]).config.system.build.sdImage;

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
