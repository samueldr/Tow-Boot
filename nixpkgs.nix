let
  rev = "8ea014acc33da95ea56c902229957d8225005163";
  sha256 = "1p3fv1zn3kf2r2nr0p6aqj7gns31krxhp0rsl8pfdmand7z5a5jd";
  tarball = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    inherit sha256;
  };
in
builtins.trace "Using default Nixpkgs revision '${rev}'..." (import tarball)
