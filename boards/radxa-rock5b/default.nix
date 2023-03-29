/*

https://github.com/radxa/u-boot/tree/stable-5.10-rock5
https://github.com/radxa/rkbin

*/
{ config, lib, pkgs, ... }:

let
  blobs = pkgs.callPackage ./blobs.nix { };
  inherit (blobs) BL31 ram_init;
in
{
  device = {
    manufacturer = "Radxa";
    name = "ROCK 5B";
    identifier = "radxa-rock5b";
    productPageURL = "https://wiki.radxa.com/Rock5/hardware/5b";
  };

  hardware = {
    soc = "rockchip-rk3588";
    SPISize = 16 * 1024 * 1024; # 16 MiB
  };

  Tow-Boot = {
    defconfig = "rock-5b-rk3588_defconfig";
    config = [
      (helpers: with helpers; {
        USB_GADGET_MANUFACTURER = freeform ''"Radxa"'';
      })
      (helpers: with helpers; {
        SYS_MMCSD_RAW_MODE_U_BOOT_USE_PARTITION = no;
        # Offset for U-Boot proper is hardcoded in our builder
        # 0x80000 / 512
        MTD_BLK_U_BOOT_OFFS = freeform "0x400";
        SPL_LIBDISK_SUPPORT = no;
      })
      # Not present in this older revision
      (helpers: with helpers; {
        AUTOBOOT_MENUKEY = lib.mkForce (option no);
        AUTOBOOT_USE_MENUKEY = lib.mkForce (option no);
        CMD_CLS = lib.mkForce (option no);
        SYSINFO = lib.mkForce (option no);
        SYSINFO_SMBIOS = lib.mkForce (option no);
      })
      # Environment is not supported with the BSP build
      (helpers: with helpers; {
        ENV_IS_NOWHERE = lib.mkForce yes;
        ENV_ADDR = lib.mkForce no;
        ENV_IS_IN_SPI_FLASH = lib.mkForce no;
        ENV_OFFSET = lib.mkForce no;
        ENV_SECT_SIZE = lib.mkForce no;
      })
      (helpers: with helpers; {
        DISABLE_CONSOLE = no;
      })
      (helpers: with helpers; {
        CMD_BOOTEFI_HELLO_COMPILE = no;
        EFI_LOADER = yes;
      })
      (helpers: with helpers; {
        OPTEE_CLIENT = no;
        ANDROID_BOOTLOADER = no;
        ANDROID_BOOT_IMAGE = no;
      })
    ];

    uBootVersion = "2017.09";
    src = pkgs.fetchFromGitHub {
      owner = "samueldr";
      repo = "u-boot";
      rev = "8a22101502b8a1525027eacd43e9fa3243b54cf0";
      sha256 = "sha256-TCN7boIb66YWh8S1GOW93kDWisQlpgcde8az0ZA5ckk=";
    };

    # This is based on the Rockchip BSP
    useDefaultPatches = false;

    # Disable features causing trouble
    withLogo = false;

    builder.additionalArguments = {
      inherit BL31;
    };

    builder.preBuild = ''
      substituteInPlace arch/arm/mach-rockchip/decode_bl31.py \
        --replace "/usr/bin/env python2" "${pkgs.buildPackages.python2}/bin/python2"
    '';

    builder.installPhase = lib.mkMerge [
      # https://github.com/radxa/build/blob/428769f2ab689de27927af4bc8e7a9941677c366/mk-uboot.sh#L341-L347
      (lib.mkBefore ''

        echo ':: Building specific outputs for the proprietary flavoured bits'
        (PS4=" $ "; set -x
        make $makeFlags "''${makeFlagsArray[@]}" spl/u-boot-spl.bin u-boot.dtb u-boot.itb
        )
        echo ':: Building proprietary flavoured idbloader.img'
        (PS4=" $ "; set -x
        tools/mkimage \
          -n rk3588 \
          -T "rksd" \
          -d "${ram_init}:spl/u-boot-spl.bin" \
          idbloader.img
        )
      '')
    ];
  };
}
