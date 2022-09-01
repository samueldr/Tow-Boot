{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkIf
    mkMerge
    mkOption
    types
  ;
  inherit (config.hardware) mmcBootIndex;
  cfg = config.hardware.socs;
  nxpSOCs = [
    "nxp-imx8mq"
  ];
  anyNXP = lib.any (soc: config.hardware.socs.${soc}.enable) nxpSOCs;
  isPhoneUX = config.Tow-Boot.phone-ux.enable;
in
{
  options = {
    hardware.socs = {
      nxp-imx8mq.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable when SoC is NXP i.MX8";
        internal = true;
      };
    };
  };

  config = mkMerge [
    {
      hardware.socList = nxpSOCs;
    }
    (mkIf anyNXP {
      Tow-Boot = {
        # https://community.nxp.com/t5/i-MX-Processors-Knowledge-Base/i-MX8-Boot-process-and-creating-a-bootable-image/ta-p/1101253
        firmwarePartition = {
          offset = 32 * 1024; # 32KiB into the image, or 64 × 512 long sectors, or 0x8000
          length = 4 * 1024 * 1024; # Expected max size
        };
        builder.installPhase = ''
          cp -v flash.bin $out/binaries/Tow-Boot.$variant.bin
        '';
        installer.additionalMMCBootCommands = ''
          mmc dev 0 ${mmcBootIndex}
          mmc partconf 0 0 ${mmcBootIndex} 0
        '';
      };

    })
    (mkIf cfg.nxp-imx8mq.enable {
      system.system = "aarch64-linux";
      Tow-Boot.builder.additionalArguments = {
        BL31 = "${pkgs.Tow-Boot.armTrustedFirmwareIMX8MQ}/bl31.bin";
      };
    })

    # Documentation fragments
    (mkIf (anyNXP && !isPhoneUX) {
      documentation.sections.installationInstructions =
        lib.mkDefault
        (config.documentation.helpers.genericInstallationInstructionsTemplate {
          # Assumed device-dependent as it is configurable:
          #  - https://community.nxp.com/t5/i-MX-Processors-Knowledge-Base/i-MX8-Boot-process-and-creating-a-bootable-image/ta-p/1101253
          startupConflictNote = ''

            > **NOTE**: The SoC startup order for NXP systems will be device-dependent.
            >
            > You may need to prevent default startup sources from being used
            > to install using the Tow-Boot installer image.

          '';
        })
      ;
    })
  ];
}
