{ config, lib, pkgs, ... }:

let
  pw = id: sha256: pkgs.fetchpatch {
    inherit sha256;
    name = "${id}.patch";
    url = "https://patchwork.ozlabs.org/patch/${id}/raw/";
  };
in
{
  device = {
    manufacturer = "PINE64";
    name = "Pinephone (A64)";
    identifier = "pine64-pinephoneA64";
    productPageURL = "https://www.pine64.org/pinephone/";
  };

  hardware = {
    soc = "allwinner-a64";
    mmcBootIndex = "1";
  };

  Tow-Boot = {
    defconfig = "pinephone_defconfig";
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
    config = [
      (helpers: with helpers; {
        BUTTON_GPIO = yes;
        BUTTON_SUN4I_LRADC = yes;
        LED_GPIO = yes;
        VIBRATOR_GPIO = yes;
      })
      (helpers: with helpers; {
        USB_MUSB_GADGET = yes;
        USB_GADGET_MANUFACTURER = freeform ''"Pine64"'';
      })
    ];
    patches = [
      ./0001-Enable-led-and-vibrate-on-boot-to-notify-user-of-boo.patch
      ./0001-HACK-button-sun4i-lradc-Provide-UCLASS_BUTTON-driver.patch
      ./0001-HACK-cmd-ums-Ensure-USB-gadget-is-probed-via-workaro.patch
    ];
    touch-installer = {
      targetBlockDevice = "/dev/mmcblk2boot0";
    };
  };
  documentation.sections.installationInstructions = builtins.readFile ./INSTALLING.md;
}
