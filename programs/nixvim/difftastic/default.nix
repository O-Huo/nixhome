{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ (pkgs.callPackage ./package.nix { }) ];
    extraPackages = with pkgs; [
      difftastic
      jujutsu
    ];

    extraConfigLua = ''
      require("difftastic-nvim").setup({
        download = false, -- The native library is built by Nix.
        vcs = "jj",
        highlight_mode = "treesitter",
      })
    '';

    keymaps = [
      {
        key = "<leader>jj";
        action = "<cmd>Difft @<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Review current jj change";
        };
      }
      {
        key = "<leader>jp";
        action = "<cmd>Difft @-<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Review parent jj change";
        };
      }
      {
        key = "<leader>jq";
        action = "<cmd>DifftClose<CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Close jj diff";
        };
      }
    ];

    plugins.which-key.settings.spec = [
      {
        __unkeyed-1 = "<leader>j";
        group = "Jujutsu";
      }
    ];
  };
}
