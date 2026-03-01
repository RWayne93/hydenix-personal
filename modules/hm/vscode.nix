{ pkgs, ... }:

{
  # VSCode reads password-store from argv.json; keep it for CLI launches
  home.file.".config/Code/User/argv.json" = {
    text = ''
      {
        "password-store": "gnome-libsecret"
      }
    '';
    force = true;
    mutable = true;
  };

  # Override VSCode desktop entries so launchers pass password-store flag
  home.file.".local/share/applications/code.desktop" = {
    text = ''
      [Desktop Entry]
      Actions=new-empty-window
      Categories=Utility;TextEditor;Development;IDE
      Comment=Code Editing. Redefined.
      Exec=code --password-store=gnome-libsecret %F
      GenericName=Text Editor
      Icon=vscode
      Keywords=vscode
      Name=Visual Studio Code
      StartupNotify=true
      StartupWMClass=Code
      Type=Application
      Version=1.5

      [Desktop Action new-empty-window]
      Exec=code --password-store=gnome-libsecret --new-window %F
      Icon=vscode
      Name=New Empty Window
    '';
    force = true;
    mutable = true;
  };

  home.file.".local/share/applications/code-url-handler.desktop" = {
    text = ''
      [Desktop Entry]
      Categories=Utility;TextEditor;Development;IDE
      Comment=Code Editing. Redefined.
      Exec=code --password-store=gnome-libsecret --open-url %U
      GenericName=Text Editor
      Icon=vscode
      Keywords=vscode
      MimeType=x-scheme-handler/vscode
      Name=Visual Studio Code - URL Handler
      NoDisplay=true
      StartupNotify=true
      StartupWMClass=Code
      Type=Application
      Version=1.5
    '';
    force = true;
    mutable = true;
  };

  # Enable our own VSCode with proper keyring support
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = true;
  };

}

