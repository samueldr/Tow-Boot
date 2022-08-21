# Simply imports our overlay in Nixpkgs
{
  nixpkgs.overlays = [
    (import ../support/overlay/overlay.nix)
    (final: super: {
      # ncdu2 build is broken
      # https://github.com/NixOS/nixpkgs/issues/169461#issuecomment-1104425909
      ncdu = super.ncdu_1;
    })
  ];
}
