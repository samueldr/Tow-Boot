{ config, lib, ... }:

{
  options = {
    inputs = {
      celun = lib.mkOption {
        type = with lib.types; oneOf [ package path ];
        description = ''
          `import`able reference to celun.
        '';
        internal = true;
      };
    };
  };
  config = {
    inputs.celun = lib.mkDefault (import ../celun.nix);
  };
}
