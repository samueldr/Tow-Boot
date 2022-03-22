{ config, lib, pkgs, ... }:

let
  inherit (lib)
    escapeShellArg
    mkIf
    mkMerge
    mkOption
    types
  ;

  flash = times: lib.concatStringsSep " ; " [
    "for i in ${lib.concatStringsSep " " (lib.genList (x: toString x) times)}; do"
    "  sleep 0.2"
    "  led led-0 off"
    "  sleep 0.2"
    "  led led-0 on"
    "done"
  ];
in
{
  Tow-Boot = {
    config = [
      (helpers: with helpers; {
        BOOTCOMMAND = freeform ''"${(lib.concatStringsSep " ; " [
          # Do an unneeded check so that the GPIO state settles
          "button 'Cover'"
          "sleep 0.2"

          # Checks the cover button is held (recovery intent)
          "if button 'Cover'; then"
            "echo 'Signaling intent for recovery... Release cover button now.'"
            # Announces we're waiting for the user to stop holding the button (intent)
            # This leaves two whole seconds for the user to notice the flashing LED.
            (flash 10)

            # Checks the cover button is held (still)
            "if button 'Cover'; then"
              "echo 'Cover button still held; continuing to distro boot command.'"
            "else"
              "echo 'Cover button was released; attempting recovery boot...'"
              "devtype=mmc"
              "devnum=0"
              "prefix=/"
              "script=recovery.scr"
              "part number $devtype $devnum recovery distro_bootpart"
              "if test -e $devtype $devnum:$distro_bootpart $prefix$script; then"
                ""
                "echo 'Found recovery script...'"
                "run boot_a_script"
              "fi"

              "echo 'Failed to boot recovery script...'"
              "echo 'Resetting...'"
              "sleep 5"
              # Currently mmc device 0 breaks and returns -70 after running this :/
              "reset"
            "fi"

          "fi"
          "run distro_bootcmd"
        ])}"'';
      })
    ];
  };
}
