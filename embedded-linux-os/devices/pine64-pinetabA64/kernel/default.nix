{ stdenv, fetchFromGitHub, fetchpatch }:

# This is not actually the build derivation...
# We're co-opting this derivation as a source of truth for the version and src.
stdenv.mkDerivation rec {
  version = "5.15.0";

  src = fetchFromGitHub {
    owner = "torvalds"; # Originally megous
    repo = "linux";
    rev = "8bb7eca972ad531c9b149c0a51ab43a417385813";
    sha256 = "Ou2HOUI1sR8z03LiHAqEgOlUCOXG0yF6/Wbv+2LIWZs=";
  };

  patches = [
    (fetchpatch {
      url = "https://salsa.debian.org/Mobian-team/devices/kernels/sunxi64-linux/-/raw/mobian-5.15/debian/patches/pinetab/0209-arm64-allwinner-dts-a64-enable-K101-IM2BYL02-panel-f.patch";
      sha256 = "sha256-+hfPX5uSEjpJ/oM7HMzoXNBMJtqHvK7bJA2KwhROv70=";
    })
  ];
}
