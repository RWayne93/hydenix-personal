{ lib, ... }:

{
  # Workaround for nixpkgs e73de5be / linux-zen-7.0.12 packaging bug:
  # the kernel store path contains `vmlinuz` instead of `bzImage`.
  # See: https://github.com/NixOS/nixpkgs/issues/535850
  system.boot.loader.kernelFile = lib.mkForce "vmlinuz";
}
