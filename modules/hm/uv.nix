{ pkgs, ... }:

{
  home.packages = [
    pkgs.uv
  ];

  # Make uv use the Nix-provided Python and never download binaries.
  home.sessionVariables = {
    UV_PYTHON = "${pkgs.python3}/bin/python3";
    UV_PYTHON_DOWNLOADS = "never";
  };
}

