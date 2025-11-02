{
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      pull.rebase = false;
    };
    ignores = [
      ".venv/"
      ".direnv/"
      "*.swp"
      "*.swo"
      "*.iml"

      "build/"
      ".idea/"
      "__pycache__/"

      "*.pyc"
      "nohup.out"
      ".DS_Store"
      ".vscode/"

      "*-virtualbox/"
      ".antlr/"
      "result"
      "server exited unexpectedly"
      ".claude/"
      "settings.local.json"
    ];
  };
  programs.jujutsu = {
    enable = true;
    settings = {
      revset-aliases = {
        "immutable_heads()" = "present(trunk()) | tags()";
      };
      ui = {
        always-allow-large-revsets = true;
      };
    };
  };

}
