{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkMerge
    mkIf
  ;
  inherit (config.Tow-Boot) buildUBoot;
in
{
  device = {
    manufacturer = "PINE64";
    name = "PineTab (A64)";
    identifier = "pine64-pinetabA64";
    productPageURL = "https://www.pine64.org/pinetab/";
    supportLevel = "supported";
  };

  hardware = {
    soc = "allwinner-a64";
    mmcBootIndex = "1";
  };

  Tow-Boot = {
    defconfig = "pinetab_defconfig";
    phone-ux = {
      enable = true;
      blind = true;
      wip = {
        led_R = "led-2";
        led_G = "led-1";
        led_B = "led-0";
        mmcSD   = "0";
        mmcEMMC = "1";
      };
    };
    config = mkMerge [
      [(helpers: with helpers; {
        USB_MUSB_GADGET = yes;
        USB_GADGET_MANUFACTURER = freeform ''"Pine64"'';
      })]
      # Requires Tow-Boot patches
      (mkIf (!buildUBoot) [(helpers: with helpers;{
        BUTTON_GPIO = yes;
        BUTTON_SUN4I_LRADC = yes;
        LED_GPIO = yes;
        VIBRATOR_GPIO = yes;
      })])
    ];
    touch-installer = {
      targetBlockDevice = "/dev/mmcblk2boot0";
    };
  };
  documentation.sections.installationInstructions = builtins.readFile ./INSTALLING.md;
}
