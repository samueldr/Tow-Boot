
This is an experimental Radxa Rock 5B build of U-Boot made using the
Tow-Boot build infrastructure, and some of its semantics.


## Differences from BSP U-Boot

These differences exist to make future Tow-Boot builds a drop-in replacement.

 - Baud rate at 115200 *including* proprietary loader and RAM init

## Supported features

 - SD boot
 - eMMC boot
 - SPI install

## Not working

 - HDMI
 - USB

## Untested

(Assumed to not work)

 - NVMe boot
 - EFI

## Installation

The shared disk image can be used, it will work as expected.

### Flashing to SPI

The `spi.installer.img` image does not support the menu-based flashing
interface when used with a vendor BSP.

You can write the `spi.installer.img` image to an SD card, then with

```
=> load mmc 1:2 $kernel_addr_r Tow-Boot.spi.bin
1873408 bytes read in 152 ms (11.8 MiB/s)

=> blocksize=0x200
=> setexpr length $filesize + $blocksize
=> setexpr length $length - 1
=> setexpr length $length / $blocksize

=> mtd_blk dev 2

Device 2: Vendor: 0x2207 Rev: V1.00 Prod: sfc_nor
            Type: Hard Disk
            Capacity: 16.0 MB = 0.0 GB (32768 x 512)
... is now current device

=> mtd_blk write $kernel_addr_r 0 $length
```

<!--

load mmc 1:2 $kernel_addr_r Tow-Boot.spi.bin
blocksize=0x200; setexpr length $filesize + $blocksize; setexpr length $length - 1; setexpr length $length / $blocksize
mtd_blk dev 2; mtd_blk write $kernel_addr_r 0 $length

-->

### "Unbricking" wrong SPI Flash

> **NOTE** In normal operation this will not be needed. These instructions
> are left as a hint for developers.

<!--

TODO: verify this works

You will need to short GND and SCLK on the SPI chip. This chip is at
position *U4300* on V1.3 of the board.

```
            _________
CS#     o -|o       8|-  VCC
SO/SIO1   -|2       7|-  RESET#/SIO3
WP#/SIO2  -|3       6|-  SCLK
GND       -|4       5|-  SI/SIO0
            ¯¯¯¯¯¯¯¯¯
```

> **NOTE**: The `o` in this crude drawing refer to a silkscreen mark (white)
>           on the board and to a marked dot on the upper left of the chip.

-->
