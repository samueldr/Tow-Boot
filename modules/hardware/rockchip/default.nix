{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
    versionOlder
    versionAtLeast
  ;
  inherit (config.Tow-Boot)
    variant
    uBootVersion
  ;
  cfg = config.hardware.socs;
  withSPI = config.hardware.SPISize != null;

  firmwareMaxSize = 4 * 1024 * 1024; # MiB in bytes
  partitionOffset = 64; # in sectors
  secondOffset = 16384; # in sectors
  sectorSize = 512;

  anyRockchip = lib.any (v: v) [cfg.rockchip-rk3399.enable];
  isPhoneUX = config.Tow-Boot.phone-ux.enable;
in
{
  options = {
    hardware.socs = {
      rockchip-rk3399.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable when SoC is Rockchip RK3399";
        internal = true;
      };
    };
  };

  config = mkMerge [
    {
      hardware.socList = [
        "rockchip-rk3399"
      ];
    }
    (mkIf cfg.rockchip-rk3399.enable {
      system.system = "aarch64-linux";
      Tow-Boot = {
        config = mkIf withSPI [
          (helpers: with helpers; {
            # SPI boot Support
            MTD = yes;
            DM_MTD = yes;
            ROCKCHIP_SPI_IMAGE = mkIf (versionAtLeast uBootVersion "2022.10") yes;
            SPI_FLASH_SFDP_SUPPORT = yes;
            SPL_DM_SPI = yes;
            SPL_SPI_FLASH_SUPPORT = yes;
            SPL_SPI_LOAD = yes;
            SPL_SPI = yes;
            SPL_SPI_FLASH_TINY = no;
            SPL_SPI_FLASH_SFDP_SUPPORT = yes;
            # NOTE: Some boards may have a different value:
            #   ~/tmp/u-boot/u-boot $ grep -l -R 'u-boot,spl-payload-offset' arch/*/dts/rk*.dts*
            #    arch/arm/dts/rk3368-lion-haikou-u-boot.dtsi
            #    arch/arm/dts/rk3399-gru-u-boot.dtsi
            #    arch/arm/dts/rk3399-puma-haikou-u-boot.dtsi
            # Not an issue currently.
            SYS_SPI_U_BOOT_OFFS = freeform ''0x80000''; # 512K
            SPL_DM_SEQ_ALIAS = yes;
          })
        ];
        firmwarePartition = {
            offset = partitionOffset * 512; # 32KiB into the image, or 64 × 512 long sectors
            length = firmwareMaxSize + (secondOffset * sectorSize); # in bytes
          }
        ;
        builder = {
          additionalArguments = {
            BL31 = "${pkgs.Tow-Boot.armTrustedFirmwareRK3399}/bl31.elf";
            inherit
              firmwareMaxSize
              partitionOffset
              secondOffset
              sectorSize
            ;
          };
          installPhase = mkMerge [
            (mkIf (variant == "spi") ''
              echo ":: Preparing image for SPI flash..."
              (PS4=" $ "; set -x
              tools/mkimage -n rk3399 -T rkspi -d tpl/u-boot-tpl-dtb.bin:spl/u-boot-spl-dtb.bin spl.bin
              # 512K here is 0x80000 CONFIG_SYS_SPI_U_BOOT_OFFS
              cat <(dd if=spl.bin bs=512K conv=sync) u-boot.itb > $out/binaries/Tow-Boot.$variant.bin
              )
            '')
            (mkIf (variant != "spi") ''
              echo ":: Preparing single file firmware image for shared storage..."
              (PS4=" $ "; set -x
              dd if=idbloader.img of=Tow-Boot.$variant.bin conv=fsync,notrunc bs=$sectorSize seek=$((partitionOffset - partitionOffset))
              dd if=u-boot.itb    of=Tow-Boot.$variant.bin conv=fsync,notrunc bs=$sectorSize seek=$((secondOffset - partitionOffset))
              cp -v Tow-Boot.$variant.bin $out/binaries/
              )
            '')
          ];
        };
      };
    })

    (mkIf (anyRockchip) {
      Tow-Boot = {
        config = [
          (helpers: with helpers; {
            CMD_POWEROFF = yes;
            SYSRESET_CMD_POWEROFF = yes;
          })
        ];
        builder.postPatch =
          # The baud rate needs to be patched out to match the `CONFIG_BAUDRATE` value,
          # since this `chosen/stdout-path` value serves as the default if no `console=` param exists.
          # I don't know if it's possible with the tooling of U-Boot upstream, but if it is, they should sync that.
          ''
            echo ':: Patching stdout baud rate in rockchip device trees'
            (PS4=" $ "
            for f in arch/arm/dts/*rk3*.dts*; do
              (set -x
              sed -i -e 's/serial2:1500000n8/serial2:115200n8/' "$f"
              )
            done
            )
          ''
        ;
      };
    })

    # Documentation fragments
    (mkIf (anyRockchip && !isPhoneUX) {
      documentation.sections.installationInstructions =
        lib.mkDefault
        (config.documentation.helpers.genericInstallationInstructionsTemplate {
          startupConflictNote = ''

            > **NOTE**: The SoC startup order for Rockchip systems will
            > prefer *SPI*, then *eMMC*, followed by *SD* last.
            >
            > You may need to prevent default startup sources from being used
            > to install using the Tow-Boot installer image.

          '';
        })
      ;
    })
  ];
}
