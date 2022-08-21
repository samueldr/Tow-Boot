{ device ? null
, configuration
# `import` able reference to celun
, celun
}:

import (celun + "/lib/eval-with-configuration.nix") ({
  inherit device;
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
