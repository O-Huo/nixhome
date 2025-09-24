{ pkgs, lib, inputs, ... }: {
  home.packages = with pkgs; [
    tmux
  ];

  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    terminal = "tmux-256color";
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";
    extraConfig = ''
      set -gq allow-passthrough on
      set -g visual-activity off
      set -g pane-base-index 1
      set -g renumber-windows on
      set -s escape-time 0
      set-option -g default-shell ${pkgs.fish}/bin/fish
      set-option -g default-command ${pkgs.fish}/bin/fish
      
      # Visual mode key bindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };
}
