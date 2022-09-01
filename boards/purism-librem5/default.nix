{ config, lib, pkgs, ... }:

let
  librem5ProprietaryTraining = pkgs.runCommandNoCC "librem5-proprietary-training" (rec {
    version = "8.12";
    src = pkgs.fetchurl {
      url = "https://www.nxp.com/lgfiles/NMG/MAD/YOCTO/firmware-imx-${version}.bin";
      sha256 = "sha256-a2dHvzbsxT44UjSv3OAfacV3Wt8NZoXIhSgcpuTjIu8=";
    };
    meta = with lib; {
      license = licenses.unfreeRedistributableFirmware;
    };
  }) ''
    mkdir -p $out
    cp $src installer.bin
    chmod +x installer.bin
    ./installer.bin --auto-accept
    cp -vt $out \
      */firmware/ddr/synopsys/lpddr4*.bin \
      */firmware/hdmi/cadence/signed*.bin
  '';

  # Vendor fork, for now
  TF-A = pkgs.Tow-Boot.armTrustedFirmwareIMX8MQ.overrideAttrs({ ... }: {
    src = pkgs.fetchFromGitLab {
      domain = "source.puri.sm";
      owner = "Librem5";
      repo = "arm-trusted-firmware";
      rev = "92c2de12d36b31938ce940d5cac3c30a98665237";
      sha256 = "sha256-vlRI7Z5f8GQythI0g4G9u05STCvA/Qw3YUQrC3f5BYY=";
    };
  });
in
{
  device = {
    manufacturer = "Purism";
    name = "Librem 5";
    identifier = "purism-librem5";
    productPageURL = "https://puri.sm/products/librem-5/";
  };

  hardware = {
    soc = "nxp-imx8mq";
    # Winbond W25Q16JVUXIM TR SPI NOR Flash, 3V, 16M-bit
    # TODO: check if it is configured to start from SPI.
    # SPISize = 16 / 8 * 1024 * 1024; # 16Mb → 2MB
    # TODO: determine the index
    mmcBootIndex = "1";
  };

  Tow-Boot = {
    src = pkgs.fetchFromGitLab {
      domain = "source.puri.sm";
      owner = "Librem5";
      repo = "uboot-imx";
      rev = "cf03130d32f69fb78f404d64f1262b7f5c9ce4b5"; # upstream/librem5
      sha256 = "sha256-+puBpx4StffFdrXdLv2SdadevdGxqLi974IQxgvQyls=";
    };
    useDefaultPatches = false; # until ported to 2022.04

    builder = {
      preBuild = ''
        cp -vt . ${librem5ProprietaryTraining}/*
        cp $BL31 bl31.bin
      '';
      additionalArguments = {
        BL31 = lib.mkForce "${TF-A}/bl31.bin";
      };
      makeFlags = [
        "BINMAN_DEBUG=1"
        "BINMAN_VERBOSE=3"
      ];
    };

    defconfig = "librem5_defconfig";
    ## phone-ux = {
    ##   enable = true;
    ##   blind = true;
    ##   wip = {
    ##     led_R = "led-red";
    ##     led_G = "led-green";
    ##     led_B = "led-blue";
    ##     mmcSD   = "1";
    ##     mmcEMMC = "0";
    ##   };
    ## };

    # Does not build right now, anyway blind UX.
    withLogo = false;
    config = [
      (helpers: with helpers; {
        # I assume due to the missing display support in defconfig?
        CMD_CLS = lib.mkForce no;
      })

      #(helpers: with helpers; {
      #  BUTTON_GPIO = yes;
      #  BUTTON_ADC = yes;
      #  LED_GPIO = yes;
      #  VIBRATOR_GPIO = yes;
      #})
      #(helpers: with helpers; {
      #  USB_GADGET_MANUFACTURER = freeform ''"Pine64"'';
      #})
      #(helpers: with helpers; {
      #  CMD_POWEROFF = lib.mkForce yes;
      #})
      #(helpers: with helpers; {
      #  # Workarounds required for eMMC issues and current patchset.
      #  MMC_IO_VOLTAGE = yes;
      #  MMC_SDHCI_SDMA = yes;
      #  MMC_SPEED_MODE_SET = yes;
      #  MMC_UHS_SUPPORT = yes;
      #  MMC_HS400_ES_SUPPORT = yes;
      #  MMC_HS400_SUPPORT = yes;
      #})
    ];
    ## patches = [
    ##   #
    ##   # Generic changes, not device specific
    ##   #

    ##   # Upstreamable
    ##   ./0001-adc-rockchip-saradc-Implement-reference-voltage.patch
    ##   ./0001-mtd-spi-nor-ids-Add-GigaDevice-GD25LQ128E-entry.patch

    ##   # Non-upstreamable
    ##   ./0001-HACK-Do-not-honor-Rockchip-download-mode.patch
    ##   ./0001-rk8xx-poweroff-support.patch

    ##   # Subject: [PATCH] phy: rockchip: inno-usb2: fix hang when multiple controllers exit
    ##   # https://patchwork.ozlabs.org/project/uboot/patch/20210406151059.1187379-1-icenowy@aosc.io/
    ##   (pkgs.fetchpatch {
    ##     url = "https://patchwork.ozlabs.org/series/237654/mbox/";
    ##     sha256 = "0aiw9zk8w4msd3v8nndhkspjify0yq6a5f0zdy6mhzs0ilq896c3";
    ##   })

    ##   #
    ##   # Device-specific changes
    ##   #

    ##   ./0001-pine64-pinephonepro-device-enablement.patch
    ## ];
  };
  ## documentation.sections.installationInstructions = builtins.readFile ./INSTALLING.md;
}

