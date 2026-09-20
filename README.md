# ![SchnitzelOS](assets/SchnitzelOS.svg)

This is my personal Fedora Atomic image (using
[Universal Blue's template](https://github.com/ublue-os/image-template/))
that I use on my desktop. I found that the other Universal Blue images
(Bluefin, Bazzite, Aurora) have too much stuff that I don't need that is
preinstalled and so I'd prefer starting from a clean base, like Silverblue, and
add to it.

## How to install

Right now I'm not building any ISOs so to use it:

1. Turn off secure boot (read [later section on how to re-enable
   it](#secure-boot))

1. Install (or use existing) Fedora Silverblue or any Fedora Atomic distro that
   uses GNOME (eg. Bluefin, Bazzite-GNOME).

   Starting from a non-GNOME image like Kinoite might still work but since this
   image use GNOME some configuration files may be messed up.

1. Rebase to SchnitzelOS with:

    ```bash
    sudo bootc switch ghcr.io/jmmabanta/schnitzel-os
    ```

1. After a reboot, you will then boot into SchnitzelOS!

   If you had Fedora's Flatpak remote enabled, then it will be deleted.
   Any Flatpaks installed from Fedora's remote will migrate automatically to
   Flathub.

1. Once you have verified everything is working to your liking, rebase from the
   unsigned image to the signed image for better security, then reboot:

    ```bash
    sudo bootc switch --enforce-container-sigpolicy ghcr.io/jmmabanta/schnitzel-os
    ```

## Secure Boot

If after rebasing the OS fails to boot due to secureboot, here is how to enroll
the key:

1. Disable secure boot in bios
1. After rebase, enter:

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

## Niri

By default, you will still boot into GNOME. If you want to switch to Niri then
logout and choose Niri in the login screen by clicking the cog button on the
bottom right.

A starter Niri config is provided in `/etc/niri`. If you want to make your own
Niri config then you should make your Niri config in `~/.config/niri`. You can
also use the provided Niri config as a start:

```bash
cp -r /etc/niri/ ~/.config/niri/
```

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

## NVIDIA Container Toolkit

The NVIDIA Container Toolkit should be preinstalled but if you are getting
`Failed to initialize NVML: Insufficient Permissions` then it means SELinux
might be goofy.

To fix this, run:

```bash
sudo setsebool -P container_use_devices 1
```

Note that there might be security implications that I don't know of with this
setting. What I do know though it that it fixes the problem :)

### Acknowledgements

Since the documentation for the image template is not that clear (to me at
least), I've referenced the following repos to see how they did things,
especially with how they installed things like the NVIDIA driver:

- <https://github.com/ublue-os/bazzite>
- <https://github.com/thiagojedi/kamino>
- <https://github.com/get-aurora-dev/common>
- <https://github.com/ublue-os/aurora/>
