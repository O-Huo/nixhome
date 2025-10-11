{
  description = "My Nix environment";
  inputs = {
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
      inputs.quickshell.follows = "quickshell";  # Use same quickshell version
    };
    catppuccin.url = "github:catppuccin/nix";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    nur.url = "github:nix-community/nur";
    hyprshell.url = "github:H3rmt/hyprshell?ref=hyprshell-release";
    hyprshell.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { nixpkgs
    , home-manager
    , nixvim
    , vscode-server
    , nur
    , catppuccin
    , hyprshell
    , ...
    } @ inputs:
    let
      pkgsX86 = import nixpkgs {
        system = "x86_64-linux";
      };
      pkgsArm = import nixpkgs {
        system = "aarch64-darwin";
      };

      # Import shells function properly
      importShells = pkgs: import ./shells.nix pkgs;
    in
    {
      packages = home-manager.packages; # Support bootstrapping Home Manager.

      nixosConfigurations = {
        "pittsburgh" =
          nixpkgs.lib.nixosSystem
            {
              modules = [
                nur.modules.nixos.default
                vscode-server.nixosModules.default
                ./hosts/pittsburgh
              ];
              specialArgs = { inherit inputs; };
            };
        "madison" =
          nixpkgs.lib.nixosSystem
            {
              modules = [
                nur.modules.nixos.default
                vscode-server.nixosModules.default
                ./hosts/madison
              ];
              specialArgs = { inherit inputs; };
            };
        "octal" =
          nixpkgs.lib.nixosSystem
            {
              modules = [
                nur.modules.nixos.default
                vscode-server.nixosModules.default
                ./hosts/octal
              ];
              specialArgs = { inherit inputs; };
            };
        "ruby" =
          nixpkgs.lib.nixosSystem
            {
              modules = [
                nur.modules.nixos.default
                vscode-server.nixosModules.default
                ./hosts/ruby
              ];
              specialArgs = { inherit inputs; };
            };
        "jex" =
          nixpkgs.lib.nixosSystem
            {
              modules = [
                nur.modules.nixos.default
                vscode-server.nixosModules.default
                ./hosts/jex
              ];
              specialArgs = { inherit inputs; };
            };
      };

      homeConfigurations = {
        "aoli@ruby" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsX86;
          modules = [
            ./programs/accounts/aoli.nix
            ./programs/hosts/ruby.nix
            ./programs/hyprland
            ./home.nix
            nixvim.homeModules.nixvim
            catppuccin.homeModules.catppuccin
          ];
          extraSpecialArgs = { inherit inputs; };
        };
        "aoli@octal" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsX86;
          modules = [
            ./programs/accounts/aoli.nix
            ./programs/hosts/octal.nix
            ./programs/hyprland
            ./home.nix
            nixvim.homeModules.nixvim
            catppuccin.homeModules.catppuccin
          ];
          extraSpecialArgs = { inherit inputs; };
        };
        "aoli@jex" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsX86;
          modules = [
            ./programs/accounts/aoli.nix
            ./programs/hyprland
            ./programs/hosts/jex.nix
            ./home.nix
            nixvim.homeModules.nixvim
            catppuccin.homeModules.catppuccin
          ];
          extraSpecialArgs = { inherit inputs; };
        };
        "hao@linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsX86;
          modules = [
            ./programs/accounts/hao.nix
            ./programs/hyprland
            ./home.nix
            nixvim.homeModules.nixvim
            catppuccin.homeModules.catppuccin
          ];
          extraSpecialArgs = { inherit inputs; };
        };
        "aoli@darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsArm;
          modules = [
            ./programs/accounts/aoli.nix
            ./home.nix
            nixvim.homeModules.nixvim
            catppuccin.homeModules.catppuccin
          ];
        };
      };

      # Properly structure devShells
      devShells = {
        "x86_64-linux" = importShells pkgsX86;
        "aarch64-darwin" = importShells pkgsArm;
      };
    };
}
