{ pkgs, ... }:

{
  home.packages = [
    pkgs.uv
  ];

  # Never let uv download its own Python binaries.
  home.sessionVariables = {
    UV_PYTHON_DOWNLOADS = "never";
  };
}

