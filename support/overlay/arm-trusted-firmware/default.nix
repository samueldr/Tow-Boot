# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: Copyright (c) 2003-2021 Eelco Dolstra and the Nixpkgs/NixOS contributors
# SPDX-FileCopyrightText: Copyright (c) 2021 Samuel Dionne-Riel and respective contributors
#
# This file originates from the Nixpkgs project.
# It does not need to be kept synchronized.
#
# Origin: https://github.com/NixOS/nixpkgs/blob/0cbb80e7f162fac25fdd173d38136068ed6856bb/pkgs/misc/arm-trusted-firmware/default.nix

{ lib, stdenv, fetchFromGitHub, openssl, pkgsCross, buildPackages }:

let
  buildArmTrustedFirmware = { filesToInstall
            , installDir ? "$out"
            , platform ? null
            , extraMakeFlags ? []
            , extraMeta ? {}
            , version ? "2.12"
            , ... } @ args:
           stdenv.mkDerivation ({

    name = "arm-trusted-firmware${lib.optionalString (platform != null) "-${platform}"}-${version}";
    inherit version;

    src = fetchFromGitHub {
      owner = "ARM-software";
      repo = "arm-trusted-firmware";
      rev = "v${version}";
      sha256 = "sha256-PCUKLfmvIBiJqVmKSUKkNig1h44+4RypZ04BvJ+HP6M=";
    };

    depsBuildBuild = [ buildPackages.stdenv.cc ];

    # For Cortex-M0 firmware in RK3399
    nativeBuildInputs = [ pkgsCross.arm-embedded.stdenv.cc ];
    # Make the new toolchain guessing (from 2.11+) happy
    # https://github.com/ARM-software/arm-trusted-firmware/blob/4ec2948fe3f65dba2f19e691e702f7de2949179c/make_helpers/toolchains/rk3399-m0.mk#L21-L22
    rk3399-m0-oc = "${pkgsCross.arm-embedded.stdenv.cc.targetPrefix}objcopy";

    buildInputs = [ openssl ];

    makeFlags = [
      "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
      # Make the new toolchain guessing (from 2.11+) happy
      "AS=${stdenv.cc.targetPrefix}cc"
      "OD=${stdenv.cc.targetPrefix}objdump"
    ] ++ (lib.optional (platform != null) "PLAT=${platform}")
      ++ extraMakeFlags;

    installPhase = ''
      runHook preInstall

      mkdir -p ${installDir}
      cp ${lib.concatStringsSep " " filesToInstall} ${installDir}

      runHook postInstall
    '';

    hardeningDisable = [ "all" ];
    dontStrip = true;

    # Fatal error: can't create build/sun50iw1p1/release/bl31/sunxi_clocks.o: No such file or directory
    enableParallelBuilding = false;

    meta = with lib; {
      homepage = "https://github.com/ARM-software/arm-trusted-firmware";
      description = "A reference implementation of secure world software for ARMv8-A";
      license = licenses.bsd3;
      maintainers = with maintainers; [ lopsided98 ];
    } // extraMeta;
  } // builtins.removeAttrs args [ "extraMeta" ]);

in {
  inherit buildArmTrustedFirmware;

  armTrustedFirmwareTools = buildArmTrustedFirmware rec {
    extraMakeFlags = [
      "HOSTCC=${stdenv.cc.targetPrefix}gcc"
      "fiptool" "certtool"
    ];
    filesToInstall = [
      "tools/fiptool/fiptool"
      "tools/cert_create/cert_create"
    ];
    postInstall = ''
      mkdir -p "$out/bin"
      find "$out" -type f -executable -exec mv -t "$out/bin" {} +
    '';
  };

  armTrustedFirmwareAllwinner = buildArmTrustedFirmware rec {
    platform = "sun50i_a64";
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = ["build/${platform}/release/bl31.bin"];
  };

  armTrustedFirmwareQemu = buildArmTrustedFirmware rec {
    platform = "qemu";
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = [
      "build/${platform}/release/bl1.bin"
      "build/${platform}/release/bl2.bin"
      "build/${platform}/release/bl31.bin"
    ];
  };

  armTrustedFirmwareRK3328 = buildArmTrustedFirmware rec {
    extraMakeFlags = [ "bl31" ];
    platform = "rk3328";
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = [ "build/${platform}/release/bl31/bl31.elf"];
  };

  armTrustedFirmwareRK3399 = buildArmTrustedFirmware rec {
    extraMakeFlags = [ "bl31" ];
    platform = "rk3399";
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = [ "build/${platform}/release/bl31/bl31.elf"];
  };

  armTrustedFirmwareS905 = buildArmTrustedFirmware rec {
    extraMakeFlags = [ "bl31" ];
    platform = "gxbb";
    extraMeta.platforms = ["aarch64-linux"];
    filesToInstall = [ "build/${platform}/release/bl31.bin"];
  };
}
