{ lib, ... }:

{
  device = {
    manufacturer = "FriendlyELEC";
    name = "NanoPi M1";
    identifier = "friendlyElec-nanoPiM1";
    productPageURL = "http://nanopi.io/nanopi-m1.html";
  };

  hardware = {
    soc = "allwinner-h3";
    allwinner.crust.defconfig = "nanopi_m1_defconfig";
  };

  Tow-Boot = {
    defconfig = "nanopi_m1_defconfig";
  };
}
