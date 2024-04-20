{ config, lib, pkgs, ... }:

{
  device = {
    manufacturer = "QEMU";
    name = "x86_64";
    identifier = "qemu-x86_64";
    inRelease = false;
    supportLevel = "unsupported";
  };

  hardware = {
    soc = "generic-x86_64";
  };

  Tow-Boot = {
    defconfig = "qemu-x86_64_defconfig";
    config = [
      (helpers: with helpers; {
        CMD_BMP = lib.mkForce no;
        CMD_POWEROFF = lib.mkForce no;
        # undefined reference to `env_get'
        SPL_ENV_SUPPORT = yes;
      })
    ];
    builder.installPhase = ''
      echo ":: Copying QEMU ROM file..."
      (PS4=" $ "; set -x
      cp -v u-boot.rom $out/binaries/Tow-Boot.$variant.rom
      )
    '';
  };

  build.default = lib.mkForce config.Tow-Boot.outputs.firmware;
}
