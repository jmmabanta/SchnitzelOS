# How To Install

> [!IMPORTANT]
> An active internet connection is required during installation.

1. Turn off secure boot (read [later section on how to re-enable
   it](https://github.com/jmmabanta/SchnitzelOS#secure-boot))

1. Download the [latest ISO](https://github.com/jmmabanta/SchnitzelOS/releases/latest)
   and flash it to a USB Drive (>4GB).

   Use something like [Fedora Media Writer](https://fedoraproject.org/workstation/download/)
   or [Balana Etcher](https://etcher.balena.io/) to flash it to a USB drive.

   (Optional) You should check the sha256sum of your downloaded ISO. On Linux,
   download both the .iso and .sha256 file into the same directory and run:
   `sha256sum -c SchnitzelOS-Installer.iso.sha256`.

1. Plug USB into computer and boot into it (check BIOS/UEFI settings)

1. Once the installer boots, set your language and keyboard then hit done.

1. Click "Network and Host Name" to configure your internet connection if it has
   not been automatically configures (ie. WiFi, Ethernet)

1. Click "Installation Destination" and configure which drive you want to
   install SchnitzelOS to.

   Dual booting on the same drive is not tested so I highly recommend installing
   to a separate drive.

1. Click "User Creation" and configure your user account.

   I recommend keeping "Root Account" disabled.

1. Once everything is set, click done to proceed with the installation. You
   would then be prompted to reboot once finished.

> [!NOTE]
> Once you've booted into SchnitzelOS and logged in, wait a few minutes for
> applications to install in the background (ie. Firefox, Video Player, etc.).
> This occurs only on the first login and you can monitor its progress with:
> `journalctl -u flatpak-preinstall.service -b -f`
