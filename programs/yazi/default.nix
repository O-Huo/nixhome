{ ... }: 
{

  programs.yazi = {
    enable = true;
    shellWrapperName = "yy";
    keymap = {
      mgr.prepend_keymap = [
        { run = "shell -- dragon-drop -x -i -T \"$0\""; on = [ "<C-n>" ]; }
        { run = ["shell -- for path in \"$@\"; do echo \"file://$path\"; done | wl-copy -t text/uri-list" "yank"]; on = ["y"];}
      ];
    };
  };
}
