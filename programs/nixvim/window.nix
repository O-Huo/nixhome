{
  programs.nixvim = {
    plugins = {
      lualine = {
        enable = true;
        settings = {
          optionstheme = "horizon";
          settings.options.disabled_filetypes =
            let
              disabled = [
                "NvimTree"
                "NVimTree"
                "NvimTree_1 "
                "toggleterm"
              ];
            in
              {
              statusline = disabled;
              winbar = disabled;
            };
        };
      };

      which-key = {
        enable = true;
      };

      bufferline = {
        enable = true;

        settings.options = {
          buffer_close_icon = null;
          close_icon = null;
          always_show_bufferline = false;
          separator_style = "slant";
          diagnostics = "nvim_lsp";
          offsets = [
            { filetype = "NvimTree"; }
            { text = "File Explorer"; }
            { highlight = "Directory"; }
            { separator = true; }
          ];
        };
      };

      toggleterm = {
        enable = true;
        settings.float_opts.border = "curved";
      };

      nvim-tree = {
        enable = true;
        settings = {
          git = {
            enable = true;
            ignore = false;
          };
          renderer = {
            icons = {
              glyphs = {
                default = "󰈚 ";
                folder = {
                  default = " ";
                  empty = " ";
                  open = " ";
                  symlink = " ";
                };
                git = {
                  unmerged = "";
                };
              };
            };
          };
          update_focused_file = {
            enable = true;
            update_root = true;
          };
          view.side = "left";
        };
      };
      bufdelete.enable = true; # Replacement for bdelete that keeps windows intact
    };

    keymaps = [
      {
        key = "<leader>x";
        action = ":Bdelete <CR>";
        mode = "n";
        options = {
          silent = true;
          desc = "Delete buffer";
        };
      }
    ];
  };
}
