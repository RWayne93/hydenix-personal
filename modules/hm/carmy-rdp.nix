{ config, pkgs, ... }:

let
  iconSource = ../../microsoft-rdp-icon.png;
  carmyPython = pkgs.python3.withPackages (ps: [
    ps.selenium
    ps.pexpect
  ]);
in
{
  home.packages = [
    pkgs.chromedriver
  ];

  home.file.".local/share/carmy/cArmy_login.py" = {
    source = ../../scripts/cArmy_login.py;
    executable = true;
  };

  home.file.".local/share/carmy/cArmy_login.sh" = {
    source = ../../scripts/cArmy_login.sh;
    executable = true;
  };

  home.file.".local/bin/carmy-login" = {
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      export CARMY_PYTHON="${carmyPython}/bin/python3"
      export CHROME_BINARY="${pkgs.chromium}/bin/chromium"
      export PATH="${pkgs.chromedriver}/bin:$PATH"
      export KEEP_BROWSER="''${KEEP_BROWSER:-0}"
      export CLOSE_BROWSER_AFTER_REDIRECT="''${CLOSE_BROWSER_AFTER_REDIRECT:-1}"
      export CLOSE_BROWSER_AFTER_ROUNDS="''${CLOSE_BROWSER_AFTER_ROUNDS:-2}"
      export STOP_LOG_AFTER_REDIRECT="''${STOP_LOG_AFTER_REDIRECT:-1}"
      export STOP_LOG_AFTER_ROUNDS="''${STOP_LOG_AFTER_ROUNDS:-2}"

      lock_file="''${XDG_RUNTIME_DIR:-/tmp}/carmy-login.lock"
      if ! ${pkgs.util-linux}/bin/flock -n "$lock_file" true; then
        echo "[carmy-login] already running; exiting." >> "''${XDG_STATE_HOME:-$HOME/.local/state}/cArmy_login.log"
        exit 0
      fi

      XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"
      mkdir -p "$XDG_STATE_HOME"
      LOG_FILE="$XDG_STATE_HOME/cArmy_login.log"

      {
        echo "[carmy-login] starting at $(date -Is)"
        echo "[carmy-login] CARMY_PYTHON=$CARMY_PYTHON"
        echo "[carmy-login] PATH=$PATH"
      } >> "$LOG_FILE"

      exec "${config.home.homeDirectory}/.local/share/carmy/cArmy_login.sh" "$@" >>"$LOG_FILE" 2>&1
    '';
    executable = true;
  };

  home.file.".local/share/icons/carmy-rdp.png" = {
    source = iconSource;
  };

  home.file.".local/share/applications/carmy-rdp.desktop" = {
    text = ''
      [Desktop Entry]
      Name=cArmy RDP
      Comment=Automated smartcard login for cArmy RDP
      Exec=${config.home.homeDirectory}/.local/bin/carmy-login
      TryExec=${config.home.homeDirectory}/.local/bin/carmy-login
      Icon=carmy-rdp
      Type=Application
      Terminal=false
      Categories=Network;RemoteAccess;
      StartupWMClass=cArmy-Dev-RDP
    '';
  };
}

