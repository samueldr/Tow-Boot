{ lib, ... }:

{
  device = {
    manufacturer = "FriendlyELEC";
    name = lib.mkDefault "NanoPi M1";
    identifier = lib.mkDefault "friendlyElec-nanoPiM1";
    productPageURL = "http://nanopi.io/nanopi-m1.html";
  };

  hardware = {
    soc = "allwinner-h3";
    allwinner.crust.defconfig = "nanopi_m1_defconfig";
  };

  Tow-Boot = {
    defconfig = lib.mkDefault "nanopi_m1_defconfig";
  };
}
