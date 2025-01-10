## Installation instructions

### Installing to eMMC Boot (recommended)

By installing Tow-Boot to eMMC Boot, your *PINE64 Pinetab (A64)* will be able
to start using standards-based booting without conflicting with the
operating system storage.

To do so, you will need to write the eMMC Boot installer image to a suitable
SD card.

```
# dd if=mmcboot.installer.img of=/dev/XXX bs=1M oflag=direct,sync status=progress
```

Once done, power-off your *Pinetab (A64)* and insert the
SD card in the SD card slot.

Power it on.

> Unless you know the battery is completely charged, it is recommended to
> connect the tablet to a power source. Just in case.

When starting up with Tow-Boot, which the installer image use, the display will turn on with a blue colour, or will
directly boot to the installer GUI.

In the installer GUI, select *“Install Tow-Boot to eMMC Boot”*. It is not
necessary to erase the storage before installing. Erasing the storage can be
used to uninstall Tow-Boot (or any other platform firmware installed to the
eMMC Boot partition).

Once installed, remove the installation media, and verify Tow-Boot starts from
power-on.


### Installing to shared storage

Using the shared storage strategy on the *Pinetab (A64)* can be done by
writing the `shared.disk-image.img` to an SD card or directly to eMMC.

```
 # dd if=shared.disk-image.img of=/dev/XXX bs=1M oflag=direct,sync status=progress
```
