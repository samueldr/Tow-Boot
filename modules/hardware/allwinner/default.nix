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
  allwinnerSOCs = [
    "allwinner-a64"
    "allwinner-h3"
    "allwinner-h5"
  ];
  anyAllwinner = lib.any (soc: config.hardware.socs.${soc}.enable) allwinnerSOCs;
  anyAllwinner64 = anyAllwinner && config.system.system == "aarch64-linux";
in
{
  options = {
    hardware.socs = {
      allwinner-a64.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable when SoC is Allwinner A64";
        internal = true;
      };
      allwinner-h3.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable when SoC is Allwinner H3";
        internal = true;
      };
      allwinner-h5.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable when SoC is Allwinner H5";
        internal = true;
      };
    };
  };

  config = mkMerge [
    {
      hardware.socList = allwinnerSOCs;
    }
    (mkIf anyAllwinner {
      Tow-Boot = {
        diskImage = {
          # Reduce GPT size to fit the firmware.
          gpt.partitionEntriesCount = 48;
        };
        firmwarePartition = {
            offset = 16 * 512; # 8KiB into the image, or 16 × 512 long sectors
            length = 4 * 1024 * 1024; # Expected max size
          }
        ;
        builder.installPhase = ''
          cp -v u-boot-sunxi-with-spl.bin $out/binaries/Tow-Boot.$variant.bin
        '';
        installer.additionalMMCBootCommands = ''
          mmc bootbus ${mmcBootIndex} 1 0 0
          mmc partconf ${mmcBootIndex} 1 1 1
        '';
      };
    })
    (mkIf (anyAllwinner64) {
      Tow-Boot.builder.additionalArguments = {
        BL31 = "${pkgs.Tow-Boot.armTrustedFirmwareAllwinner}/bl31.bin";
      };
    })
    (mkIf cfg.allwinner-a64.enable {
      system.system = "aarch64-linux";
    })
    (mkIf cfg.allwinner-h3.enable {
      system.system = "armv7l-linux";
      Tow-Boot.config = [
        (helpers: with helpers; {
          CMD_POWEROFF = no;
        })
      ];
    })
    (mkIf cfg.allwinner-h5.enable {
      system.system = "aarch64-linux";
    })
  ];
}
