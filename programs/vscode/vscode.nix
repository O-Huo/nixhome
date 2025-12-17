{ config, pkgs, lib, ... }: 

let
    cfg = config.programs.vscode;

    userSettingsPath = if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/Code/User"
    else
      "${config.xdg.configHome}/Code/User";
    configFilePath = "${userSettingsPath}/settings.json";
    keybindingsFilePath = "${userSettingsPath}/keybindings.json";

    pathsToMakeWritable = lib.flatten [
        (lib.optional (cfg.profiles.default.userSettings != { }) configFilePath)
        (lib.optional (cfg.profiles.default.keybindings != { }) keybindingsFilePath)
    ]; in
{

  imports = [
    ../mutable.nix
  ];

  home.file = lib.genAttrs pathsToMakeWritable (_: {
      force = true;
      mutable = true;
  });
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    
    profiles.default.extensions = with pkgs.vscode-extensions; [
      rust-lang.rust-analyzer
      ms-python.python
      ms-toolsai.jupyter
      esbenp.prettier-vscode
      vscodevim.vim
      mkhl.direnv
      jnoortheen.nix-ide
      ms-vscode-remote.vscode-remote-extensionpack
      ms-vscode-remote.remote-ssh
      ms-python.debugpy
      ms-python.pylint
      ms-python.vscode-pylance
      github.copilot
      github.copilot-chat
      tamasfe.even-better-toml
      james-yu.latex-workshop
      hediet.vscode-drawio
    ];
    
    profiles.default.userSettings = {
      "editor.experimentalGpuAcceleration" = "off";
      "editor.fontSize" = 16;
      "editor.fontFamily" = "'FiraCode Nerd Font', 'Fira Code'";
      "editor.fontLigatures" = true;
      "editor.minimap.enabled" = false;
      "terminal.integrated.fontFamily" = "'FiraCode Nerd Font', 'Fira Code'";
      "github.copilot.enable" = {
        "*" = true;
        "plaintext" = false;
        "markdown" = true;
        "scminput" = false;
      };
      "github.copilot.nextEditSuggestions.enabled" = true;
      "jupyter.askForKernelRestart" = false;
      "nix.enableLanguageServer" = true;
      "files.autoSave" = "afterDelay";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = { "command" = ["nixfmt"]; };
        };
      };
      "extensions.ignoreRecommendations" = true;
      "editor.wordWrap" = "on";
      "git.openRepositoryInParentFolders" = "never";
      "update.mode" = "none";
      "explorer.confirmDelete" = false;
    };
    
    profiles.default.keybindings = [
      {
        key = "alt+tab";
        command = "workbench.action.previousEditor";
      }
      {
        key = "alt+cmd+left";
        command = "-workbench.action.previousEditor";
      }
      {
        key = "alt+tab";
        command = "workbench.action.terminal.focusPreviousPane";
        when = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
      }
      {
        key = "alt+cmd+left";
        command = "-workbench.action.terminal.focusPreviousPane";
        when = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
      }
      {
        key = "ctrl+alt+left";
        command = "workbench.action.navigateBack";
        when = "canNavigateBack";
      }
      {
        key = "ctrl+alt+right";
        command = "workbench.action.navigateForward";
        when = "canNavigateForward";
      }
      {
        key = "ctrl+shift+left";
        command = "-cursorWordLeftSelect";
        when = "textInputFocus";
      }
      {
        key = "ctrl+shift+left";
        command = "-cursorWordAccessibilityLeftSelect";
        when = "accessibilityModeEnabled && isWindows && textInputFocus && focusedView == 'workbench.panel.output'";
      }
      {
        key = "ctrl+shift+left";
        command = "-workbench.action.terminal.resizePaneLeft";
        when = "terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
      }
      {
        key = "ctrl+alt+-";
        command = "-workbench.action.navigateBack";
        when = "canNavigateBack";
      }
      {
        key = "ctrl+shift+-";
        command = "-workbench.action.navigateForward";
        when = "canNavigateForward";
      }
      {
        key = "ctrl+alt+left";
        command = "-workbench.action.moveEditorToPreviousGroup";
      }
      {
        key = "ctrl+alt+right";
        command = "-workbench.action.moveEditorToNextGroup";
      }
      {
        key = "ctrl+alt+right";
        command = "-quickInput.acceptInBackground";
        when = "cursorAtEndOfQuickInputBox && inQuickInput && quickInputType == 'quickPick' || inQuickInput && !inputFocus && quickInputType == 'quickPick'";
      }
    ];
  };
}
