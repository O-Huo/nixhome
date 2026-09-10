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
      ".env"
      ".venv/"
      ".envrc"
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
      ".codex"
    ];
  };
  programs.jujutsu = {
    enable = true;
    settings = {
      revset-aliases = {
        "immutable_heads()" = "present(trunk()) | tags()";
      };
      aliases.push = [ "git" "push" ];
      # Publishing @ starts a new working change, including pushes from jjui.
      # Outside git push, remote bookmarks retain the normal mutability rules.
      "--scope" = [
        {
          "--when".commands = [ "git push" ];
          revset-aliases."immutable_heads()" = "present(trunk()) | tags() | remote_bookmarks()";
        }
      ];
      ui = {
        always-allow-large-revsets = true;
      };
      snapshot = {
        max-new-file-size = "50MiB";
      };
    };
  };

}
