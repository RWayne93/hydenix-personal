{ pkgs, ... }:

let
  zedEditor = pkgs.callPackage ../../pkgs/zed-editor.nix { };
in
{
  home.packages = [ zedEditor ];
}
