
This is an experimental Radxa Rock 5B build of U-Boot made using the
Tow-Boot build infrastructure, and some of its semantics.


## Differences from BSP U-Boot

These differences exist to make future Tow-Boot builds a drop-in replacement.

 - Baud rate at 115200 *including* proprietary loader and RAM init

## Supported features

 - SD boot
 - eMMC boot
 - NVMe boot
 - SPI install
 - USB Gadget (Mass Storage)

## Not working

 - HDMI
 - USB

## Untested

(Assumed to not work)

 - EFI

## Installation

The shared disk image can be used, it should work as expected.

### Flashing to SPI

The `spi.installer.img` image does not support the menu-based flashing
interface when used with a vendor BSP.

For the time being, writing to SPI flash involves the vendor programmer and
"maskrom" mode.

See the vendor information here:

 - https://wiki.radxa.com/Rock5/install/spi

> **NOTE**: if you are booting in "maskrom" mode using the button, make
> sure to remove **all** storage mediums, including SD, eMMC and NVMe.
> Depending on which component handles the download mode writes, it may
> end-up writing to any of those devices.


### "Unbricking" wrong SPI Flash

> **NOTE** In normal operation this will not be needed. These instructions
> are left as a hint for developers.

Try first using the MASKROM button on your board.

If your board is an older revision, or for some reason using the MASKROM
button does not start the system in "maskrom" mode, follow through.

To make the SoC skip the SPI Flash during startup, you will need to short
`GND` and `SCLK` on the SPI chip. This chip is at
position *U4300* on V1.3 of the board.

```
            ___________
CS#     o -|o         8|-  VCC
SO/SIO1   -|2         7|-  RESET#/SIO3
WP#/SIO2  -|3         6|-  SCLK
GND       -|4         5|-  SI/SIO0
            ¯¯¯¯¯¯¯¯¯¯¯
```

> **NOTE**: The `o` in this crude drawing refer to a silkscreen mark (white)
>           on the board and to a marked dot on the upper left of the chip.
