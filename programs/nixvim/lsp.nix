{ ... }: {
  programs.nixvim = {
    plugins = {
      lsp = {
        enable = true;
        servers = {
          # nil_ls = {
          #   enable = true;
          #   settings.nix.flake.autoArchive = true;
          # };
          # cssls.enable = true;
          # html.enable = true;
          # bashls.enable = true;
        };
      };
      # trouble.enable = true;

      noice.settings.presets."inc_rename" = true;
      inc-rename.enable = true; # Nice renaming UI
    };

    # Ability to toggle cmp
    extraConfigLua = ''
        local format_enabled = false
        vim.api.nvim_create_user_command(
            "ToggleFormatNotified",
            function()
                if format_enabled then
                    vim.cmd("FormatDisable")
                    require("notify")("Disabled formatting")
                    format_enabled = false
                else
                    vim.cmd("FormatEnable")
                    require("notify")("Enabled formatting")
                    format_enabled = true
                end
            end,
            {}
        )

      --   vim.diagnostic.config(
      --       {
      --           virtual_text = false,
      --           float = {border = "rounded"}
      --       }
      --   )
      --
      --   vim.o.updatetime = 250
      --   vim.cmd([[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
      --   vim.cmd([[autocmd! ColorScheme * highlight NormalFloat guibg=#1f2335 guifg=#abb2bf]])
      --
      -- '';
    keymaps = [
      {
        key = "<leader>fm";
        action = "<cmd> Format <CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Format Files";
        };
      }

      {
        key = "<leader>tf";
        action = "<cmd> ToggleFormatNotified <CR>";
        mode = "n";
        options.desc = "Format Toggle";
      }

      {
        key = "<Leader>ra";
        action = "<cmd> IncRename <CR>";
        mode = "n";
        options.desc = "LSP Rename";
      }

      {
        key = "<M-LeftMouse>";
        action = "<LeftMouse><cmd>lua vim.lsp.buf.definition()<CR>";
        mode = [ "n" "i" ];
        options = {
          silent = true;
          desc = "Goto definition (alt+click)";
        };
      }

      {
        key = "<M-RightMouse>";
        action = "<C-o>";
        mode = "n";
        options = {
          silent = true;
          desc = "Jump back (alt+right click)";
        };
      }

      {
        key = "<C-M-Left>";
        action = "<C-o>";
        mode = "n";
        options = {
          silent = true;
          desc = "Jump back";
        };
      }

      {
        key = "<C-M-Right>";
        action = "<C-i>";
        mode = "n";
        options = {
          silent = true;
          desc = "Jump forward";
        };
      }

      {
        key = "<X1Mouse>";
        action = "<C-o>";
        mode = "n";
        options = {
          silent = true;
          desc = "Jump back (mouse back button)";
        };
      }

      {
        key = "<X2Mouse>";
        action = "<C-i>";
        mode = "n";
        options = {
          silent = true;
          desc = "Jump forward (mouse forward button)";
        };
      }
    ];
  };
}
