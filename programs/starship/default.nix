{
  programs.starship = {
    enable = true;
    settings = {
      git_state.disabled = true;
      git_commit.disabled = true;
      git_metrics.disabled = true;
      git_branch.disabled = true;
      gradle.disabled = true;
      java.disabled = true;
      nix_shell.disabled = true;
      cmd_duration.disabled = true;
      custom = {
        git_branch = {
          when = true;
          command = "jj root >/dev/null 2>&1 || starship module git_branch";
          description = "Only show git_branch if we're not in a jj repo";
        };
        jj = {
          command = "prompt";
          format = "$output";
          ignore_timeout = true;
          shell = [
            "starship-jj"
            "--ignore-working-copy"
            "starship"
          ];
          use_stdin = false;
          when = true;
        };
      };
    };
  };
}
