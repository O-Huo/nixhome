{ ... }: 
{

  programs.yazi = {
    enable = true;
    keymap = {
     mgr.prepend_keymap = [
      { run = "shell -- dragon-drop -x -i -T \"$0\""; on = [ "<C-n>" ]; }
    ];
    };
  };
}