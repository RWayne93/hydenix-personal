{ ... }:

{
  # Override Cursor desktop entries so launchers pass --classic flag
  home.file.".local/share/applications/cursor.desktop" = {
    text = ''
      [Desktop Entry]
      Actions=new-empty-window
      Categories=Utility;TextEditor;Development;IDE
      Comment=Cursor is an AI-first coding environment.
      Exec=cursor --classic %F
      GenericName=Text Editor
      Icon=cursor
      Keywords=cursor
      Name=Cursor
      StartupNotify=true
      StartupWMClass=cursor
      Type=Application
      Version=1.5

      [Desktop Action new-empty-window]
      Exec=cursor --classic --new-window %F
      Icon=cursor
      Name=New Empty Window
    '';
    force = true;
    mutable = true;
  };

  home.file.".local/share/applications/cursor-url-handler.desktop" = {
    text = ''
      [Desktop Entry]
      Categories=Utility;TextEditor;Development;IDE
      Comment=Cursor is an AI-first coding environment.
      Exec=cursor --classic --open-url %U
      GenericName=Text Editor
      Icon=cursor
      Keywords=cursor
      MimeType=x-scheme-handler/cursor
      Name=Cursor - URL Handler
      NoDisplay=true
      StartupNotify=true
      StartupWMClass=cursor
      Type=Application
      Version=1.5
    '';
    force = true;
    mutable = true;
  };
}
