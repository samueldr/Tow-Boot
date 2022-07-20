{ runCommandNoCC, fetchurl, xxd }:

{
  BL31 = fetchurl {
    url = "https://github.com/radxa/rkbin/blob/db0c185306b5251c43ac2181fcab8ba2868d64bb/bin/rk35/rk3588_bl31_v1.25.elf?raw=true";
    sha256 = "sha256-UUkqY7+YAFxBwTCz3Ey09q+StT3B68Iqqv4aZXQhF5E=";
  };

  # Originally 60e3 16__; 0x16e360, 1500000
  # Changed to 0x1c200, 115200, 00c2 01__
  # Finding the offset: `grep '60 \?e3 \?16'`
  ram_init = 
    runCommandNoCC "rk3588-patched-ram_init" {
      nativeBuildInputs = [
        xxd
      ];
      ram_init = fetchurl {
        url = "https://github.com/radxa/rkbin/blob/db0c185306b5251c43ac2181fcab8ba2868d64bb/bin/rk35/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.07.bin?raw=true";
        sha256 = "sha256-M6XVY1VcYXffXrS0bqWS1cTyQIqJs7Ctm/sQ5K21/18=";
      };
    } ''
      cat $ram_init > $out

      xxd -r - $out <<EOF
      0000e7c0: 110d 2b0d 0000 0000 1e0d 3808 00c2 0120
      EOF
    ''
  ;
}
