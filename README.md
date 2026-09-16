# SchnitzelOS

This is my personal Fedora Atomic image (using [Universal Blue's template](https://github.com/ublue-os/image-template/)) that I use on my desktop. It is basically Fedora Silverblue + [OGC Kernel](https://opengamingcollective.org/) + Codecs + NVIDIA open drivers + Niri + Noctalia + some other programs that I'd rather have installed at the image level instead of through Homebrew or Flatpak.

I found that the other Universal Blue images (Bluefin, Bazzite, Aurora) have too much stuff that I don't need that is preinstalled and so I'd prefer starting from a clean base, like Silverblue, and add to it.

## How to install

Right now I'm not building any ISOs so to use it, first install any Fedora Atomic image with GNOME (Bluefin, Bazzite-Gnome, Fedora Silverblue). Then, rebase to this image with:
```sh
sudo bootc switch ghcr.io/jmmabanta/SchnitzelOS
```

### Acknowledgements

Since the documentation for the image template is not that clear (to me at least), I've reference the following repos to see how they did things, especially with how they installed things like the NVIDIA driver:

- https://github.com/ublue-os/bazzite
- https://github.com/thiagojedi/kamino
