{ config, lib, pkgs, ... }:

{
  device = {
    manufacturer = "QEMU";
    name = "aarch64";
    identifier = "qemu-aarch64";
    inRelease = false;
    supportLevel = "unsupported";
  };

  hardware = {
    soc = "generic-aarch64";
  };

  Tow-Boot = {
    defconfig = "qemu_arm64_defconfig";
    builder.installPhase = ''
      echo ":: Copying QEMU ROM file..."
      (PS4=" $ "; set -x
      cp -v u-boot.bin $out/binaries/Tow-Boot.$variant.rom
      )
    '';
  };

  build.default = lib.mkForce config.Tow-Boot.outputs.firmware;
}
