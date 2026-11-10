# ![SchnitzelOS](assets/SchnitzelOS.svg)

This is my personal Fedora Atomic image (using
[Universal Blue's template](https://github.com/ublue-os/image-template/))
that I use on my desktop. I found that the other Universal Blue images
(Bluefin, Bazzite, Aurora) have too much stuff that I don't need that is
preinstalled and so I'd prefer starting from a clean base, like Silverblue, and
add to it.

## Changes

It is basically just Fedora Kinoite with:

- [Codecs](https://negativo17.org/multimedia/)
- Latest [NVIDIA Open Driver](https://negativo17.org/nvidia-driver/)
- [OGC Kernel](https://opengamingcollective.org/)
  - *Should* have EAC-V2 support
- [Noctalia Greeter](https://github.com/noctalia-dev/noctalia-greeter)
  - Plasma Login Manager often gives me a black screen on boot so I just
    replaced it with noctalia greeter (based on greetd).
- Steam, Docker, and other smaller packages.
  - For a full list, see this [script](build_files/20-packages.sh)

## Install

> [!IMPORTANT]
> An active internet connection is required during installation.

1. Turn off secure boot (read [later section on how to re-enable
   it](#secure-boot))

1. Download the [latest ISO](https://github.com/jmmabanta/SchnitzelOS/releases/download/installer/SchnitzelOS-Installer.iso)
   and flash it to a USB Drive (>4GB).

   Use something like [Fedora Media Writer](https://fedoraproject.org/workstation/download/)
   or [Balana Etcher](https://etcher.balena.io/) to flash it to a USB drive.

   (Optional) You should check the sha256sum of your downloaded ISO. On Linux,
   download both the .iso and .sha256 file into the same directory and run:
   `sha256sum -c SchnitzelOS-Installer.iso.sha256`.

1. Plug USB into computer and boot into it (check BIOS/UEFI settings)

1. Once the installer boots, set your language and keyboard then hit done.

   Note that due to file size restrictions, only English is supported. There may
   be missing glyphs from other languages.

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

### Rebasing From Existing Fedora Atomic

If you have an existing Fedora Atomic install using KDE (eg. Kinoite, Aurora,
Bazzite), you can use the following commands to switch to SchnitzelOS:

```bash
sudo bootc switch ghcr.io/jmmabanta/schnitzel-os
```

After rebasing and verifying everything works to your liking, run the following
command to ensure future updates are verified:

```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/jmmabanta/schnitzel-os
```

> [!IMPORTANT]
> I've only tested rebasing from Fedora Kinoite. Rebasing from other Fedora
> Atomic distros (especially those using a different a desktop environment) may
> cause complications.

## Secure Boot

If you want to enable secure boot after installation, follow these steps:

> [!NOTE]
> If you've enrolled Universal Blue's secure boot keys (eg. Aurora, Bazzite,
> Bluefin Classic), then you don't need to follow these steps.

1. After installation, enter:

   ```bash
   sudo mokutil --import /etc/pki/akmods/certs/akmods-ublue.der
   ```

1. You will then be prompted to type a password. Type something simple like
   `1234`. It will only be temporary and you'll need to use it in the next step.
1. Reboot your computer. You will then be prompted with the MOK Manager. Choose
   to enroll the key and use the same password that you entered in the previous
   step.
1. After entering the key, continue to reboot and now the OS should be secure
   boot ready.
1. Reboot back into bios and re-enable secure boot.

## Autologin

If you want to automatically login, add the following to
`/etc/greetd/config.toml` (edit as sudo):

```toml
[initial_session]
command = "startplasma-wayland"
user = "your_username_here"
```

> [!TIP]
> If you keep getting nagged about KWallet being locked, you can replace it with
> a blank password by opening KWalletManager. Do note that this
> (obviously) impacts security.

## ZSWAP

According to Chris Down, [zswap is better than zram](https://chrisdown.name/2026/03/24/zswap-vs-zram-when-to-use-what.html)
in most cases. This image has already set the necessary kernel parameters to
enable zswap but some manual work needs to be done by you after rebasing (since
neither Fedora nor ublue-os images use a swap file by default and instead use
ZRAM).

1. Create BTRFS subvolume for swap

   ```bash
   sudo btrfs subvolume create /var/swap
   sudo semanage fcontext -a -t var_t /var/swap
   sudo restorecon /var/swap
   ```

1. Create the swapfile itself

   ```bash
   SIZE=8G
   sudo btrfs filesystem mkswapfile --size $SIZE /var/swap/swapfile
   sudo semanage fcontext -a -t swapfile_t /var/swap/swapfile
   sudo restorecon /var/swap/swapfile

   sudo swapon /var/swap/swapfile
   ```

1. Add the swapfile to `/etc/fstab` so it persists between reboots:

   ```bash
   echo "/var/swap/swapfile none swap defaults,nofail 0 0" | sudo tee -a /etc/fstab
   ```

1. Disable ZRAM:

   ```bash
   sudo touch /etc/systemd/zram-generator.conf
   ```

1. Reboot

### Acknowledgements

Since the documentation for the image template is not that clear (to me at
least), I've referenced the following repos to see how they did things,
especially with how they installed things like the NVIDIA driver:

- <https://github.com/ublue-os/bazzite>
- <https://github.com/thiagojedi/kamino>
- <https://github.com/get-aurora-dev/common>
- <https://github.com/ublue-os/aurora/>
