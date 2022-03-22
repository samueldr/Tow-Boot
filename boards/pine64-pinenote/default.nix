{ config, lib, pkgs, ... }:

let
  inherit (pkgs)
    fetchurl
  ;
  bl31 = fetchurl {
    url = "https://github.com/JeffyCN/rockchip_mirrors/blob/6186debcac95553f6b311cee10669e12c9c9963d/bin/rk35/rk3568_bl31_v1.28.elf?raw=true";
    sha256 = "sha256-Z78ZVm+2RuLx9Vt/vwhPDXG1m4daGaB35ji5Wt8bJUo=";
  };
  ram_init = fetchurl {
    url = "https://github.com/JeffyCN/rockchip_mirrors/blob/47404a141a1acb7555906b5e3b097b5f1045cc21/bin/rk35/rk3568_ddr_1560MHz_v1.11.bin?raw=true";
    sha256 = "sha256-kgG80qxX89LWnCDt6jxSi1dJvqxMz5kZB0Xg1a5GMgs=";
  };
in
{
  imports = [
    ./bootcmd.nix
  ];

  device = {
    manufacturer = "PINE64";
    name = "PineNote";
    identifier = "pine64-pinenote";
    productPageURL = "https://www.pine64.org/pinenote/";
  };

  hardware = {
    soc = "rockchip-rk3566";
  };

  Tow-Boot = {
    defconfig = "pinenote-rk3566_defconfig";
    config = [
      (helpers: with helpers; {
        BOOTDELAY = lib.mkForce (freeform "1");
      })
      (helpers: with helpers; {
        BUTTON = yes;
        BUTTON_GPIO = yes;
        LED_GPIO = yes;
        LED = yes;
      })
      (helpers: with helpers; {
        USB_GADGET_MANUFACTURER = freeform ''"Pine64"'';
      })
      (helpers: with helpers; {
        CMD_POWEROFF = lib.mkForce yes;
      })
      (helpers: with helpers; {
        # Workarounds required for eMMC issues and current patchset.
        MMC_IO_VOLTAGE = yes;
        MMC_SDHCI_SDMA = yes;
        MMC_SPEED_MODE_SET = yes;
        MMC_UHS_SUPPORT = yes;
        MMC_HS400_ES_SUPPORT = yes;
        MMC_HS400_SUPPORT = yes;
      })
    ];

    withLogo = false; # XXX

    builder.preBuild = ''
      cp ${ram_init} ram_init.bin
    '';
    builder.additionalArguments = {
      BL31 = bl31;
    };

    patches = [
      #
      # Generic changes, not device specific
      #

      # Subject: [PATCH] phy: rockchip: inno-usb2: fix hang when multiple controllers exit
      # https://patchwork.ozlabs.org/project/uboot/patch/20210406151059.1187379-1-icenowy@aosc.io/
      (pkgs.fetchpatch {
        url = "https://patchwork.ozlabs.org/series/237654/mbox/";
        sha256 = "0aiw9zk8w4msd3v8nndhkspjify0yq6a5f0zdy6mhzs0ilq896c3";
      })

      #
      # Device-specific changes
      #

      # XXX ./0001-pine64-pinenote-device-enablement.patch
    ];
  };
  documentation.sections.installationInstructions = builtins.readFile ./INSTALLING.md;
}
