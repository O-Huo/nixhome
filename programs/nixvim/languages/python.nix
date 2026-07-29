{ ... }: {
  programs.nixvim = {
    plugins.lsp.servers = {
      basedpyright = {
        enable = true;
        settings.basedpyright.analysis = {
          typeCheckingMode = "standard";
          diagnosticMode = "openFilesOnly";
        };
      };
    };
  };
}
