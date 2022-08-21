{ device ? null
, configuration
# `import` able reference to celun
, celun
# A nixpkgs ref
, pkgs
}:

import (celun + "/lib/eval-with-configuration.nix") ({
  inherit device;
  inherit pkgs;
  verbose = true;
  configuration = {
    imports = [
      ./configuration.nix
      configuration
      (
        { lib, ... }:
        {
          celun.system.automaticCross = lib.mkDefault true;
        }
      )
    ];
  };
})
