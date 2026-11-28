# dankdots

**niri on fedora with dux shell and dynamic theming**

<img alt="niri" src="https://img.shields.io/badge/niri-b6c4ff?style=flat-square&labelColor=1e1f25&logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAADyElEQVR42u3ZS2hcZRQH8N9Nk7QJUbHSWrWKKAhNHxZcuBCp0HRh66KkCJG0ClIfKC5cuVBEqVsRtfgAdSFpF9aFLtSqaaFCfYOWNgEpYhUrtVXbQsmrNtfFfJO5Ge9MJvdOZrLI2c39Xvc%2F53z%2F8z%2FnsmALlsuirAuHtvdU3jSOde85MH8BJF4%2Bwi1Ygd9wAnFxcPXA4JwDaMm5%2Fn4MYj8O4lWsjxJAq3mqKR4Y3r5RXFh2Ez7DzWVT%2FsCbeA1%2FzbU3Zu2BuIT5zpSXh2vxPN7HHcmw%2B%2F7he%2BZVCK2fYXwD9uEhtELHyJihHT3zAsAi3FDDvGvwCnahK7iwrvciK4B2LK1x7hI8hZeTa4b6e5oKoBWdsySLB7EbVxWfDPX1NBVAe4Z19%2BElXDG1S5MAtOQ4fkdgqfaZMvpcAojyyBA8hkdrkSVzSaN5ALThGdzVrBCK6kAgy%2FBc8VJn9UIeANXWjuHfGvbZgAeaxUJtFca%2Bwlbci9eDNqpmO3F9Vi%2FkSWRpNDqKF%2FApPgiXdUuQFJMV9lqFzVnjMiuAxRUAHMWXZc9%2BDEnsxSphtQXtcYOlRFoe%2BA7nUuTzBTyLtyvstxrLG30HFqU8PzbtrQYGxZNx8mLvwg8p65YGVmoqjU7g12JNXLQ1ew%2BYLFWZJ%2FFOBXXb1kgAF3Gp7Nk4%2Fsb%2FCvq1A9N%2BH0pWaon9RhsJ4ELKgRdDmKQHeelOnMLpsuHzONtIAGdxJiUMalGoEylAfyl6r1EAzgfKTFpnkUnSEtJwqZTsxGVlw4cKHo0bBiDGJ2W83oa1FRfE0xLXdYmhU%2Fgwq8TKo0b344sUbbMYjvRtnHp4vH9Tkr22lVVzb%2BFI1tbLrAEkDjmHp%2FFzYvh23AqtraV%2FcyKa%2BvtvCwCKti9UaE3rzH0d1OThREK6u8r8zbg6sNhuPI5%2FoGVysnEAylx9GL14Ah%2FjeJWl3yq0H3vxZJLJVu092PjCJIVt2sLFjpNAq3ay0Z2j7ViPyipzNVWPfmk0By9%2FOVaGnNAVzhgN8uFk9%2B83nhleeaJuIOoJYFnQ%2FVsVmr5dCYF2CSNBzA3iDfxELIpbdO%2F5PPP5uVpLQ%2F2biuF%2BZSgft1U5Z3GYtyZ0I%2FqJhuMo1jQabe8YT1ZUvWbX2d6p2V9oJsamtNu6DOG4rpi1m5nIktXWbG28SqHfcAAfKXzkq9VG8F6oIXJZvv5wXAiciG9i%2BvBI0EPL0RFqhCiw0HiQDUfxbkmBzqM8ENESF%2Bh0RWCcJeGM8VBDnMafoaiZH3kgWyYuuK4R35EXbMFmsP8AyJHwb%2BLJmcQAAAAASUVORK5CYII%3D"> <img alt="Dux Shell" src="https://img.shields.io/badge/Dux%20Shell-dce1ff?style=flat-square&labelColor=1e1f25&logo=data%3Aimage%2Fpng%3Bbase64%2CiVBORw0KGgoAAAANSUhEUgAAACoAAAAwCAYAAABnjuimAAAHqElEQVR42sWZeYxUVRbGf%2FdVdWMvLN0NHUV7ZsQGBRy7bMAFHUED2qgRREWccZwY1LjEGNuZZFSio2FiRsmEcYni8odLxDVqaIlIKYtgTAS6EMdhjA0zstmRrenqoaGW6x%2Fve9WPWqBeNYMnqVR31Xv3fu%2Fcc77znVOGABaLWkgBocxH1cAY4BzgXOBMoAEYDBhgH7ASmGegHQM93TBxhiGohQOBJANyODATmAGcBdQBTp7b6nRdg4XrsWyprKYkM4FAutdfA8wFmgLutcAYWq3FplIw7rJgXnUCbvYH4KUSQAL8zlomAIRDwW8OAvRU4EFgUGmHxzDgDiBsgfal9v8GdDTwS%2FpnM4DzAUzIDalY1LJioSW2zHLttbZ0oK3TMzcPCpJ8BWwIcDdwClALVBhgyGlu9M%2B93QW%2FotUGT6YtayxdBwC4DVhYIsAU0A10Aj8CNUAa2A18D8SA5cBX%2BpzIFFM8PbV%2FZNnfm%2Fl3YBGAkkBcYLYBHcB3wGZgu4DVAq8BI3z33aR75hl40hbLoxuillQ1mDhYexgn%2Bj10ANivDXYKSCewB%2BgV41YBQxXf9VqjXkUhX7JNt%2B6pHTwq0FjUYgEnDnr6C4BpwJWAVbXZK895C54EnCZgVUAFUB4wPH4AXsZwEHtUwt9LLDoEbTILuAtoztrUBikWWWFxUK8exeyPwFZgg0rt1zopsBCZanKBrllsqa7IoJgGvAcMCADkkDbeoZeXOLuBXXrt00l0A3ED%2B617HyoitwKPKYxIJGDCNHP40VcJpHEJuQN4FZikmDpBD5VU7HkP0C1vfAFskqe8uKwVHQ3W%2F1t0vFv0UFUWJgAnK9b%2FreT7K3AfsLusLOvofbW8DHgAWOE4rEynGa74qxXnpoBHJETeBz4X1TQpYRoErhBF7QP%2BoweqBkbJCV3AauD3QKu%2BewBIeFRlPn7dMqzOrRTAjcBU4B4tmm2TgceBD6SgLgd%2BpePdJBCdwCVAJOveZyQDJ8l7DUClYnKFwM9WIj4lXn0FC9094NTXZ0COAK4D5nsg48k%2B4jXu28XAR5Judyqx5osH7wNeBJ4DFmWBtDrWMpH6TOBd3%2FeDBD6lGJ4vldaIgYHV4Ji%2BQJ2jJ9voLX1hS1%2FWWUuFvHSTmCCpWJsM%2FANYrId4TmR%2FKCvRLgbG6zRu0RpxeTCijPfsn8CnwBwPgWPdHccqxl73rvRTg68yjfQJkzBwujZvFGEPAM4Wzy713TsAaAHagHYd8TsKs0flzVnAFNPXPywCRlk3XDJZP13B3Bmqhl%2Bfl5ci67KqUyGrkdf%2FohMaKXZYp6x%2FRH%2B%2FKRqLAc%2BqoNxv3bj%2Fm2L9M2H7OizqaNLCpOIFAdSKeoqx60U7HwhsWJ6%2FRrp2h75LKB%2B2yqtReXs0cDOwBJgHDPMWiEs8MG5KQZ1SEUDmGeA3etk8VWy43neqKFjgF7pusxrGm4EnRF0TwsBEJVDCGEiRKrR5dYl6NF8c7VYCvgFsNdCbdonaWDeea4BKY0hay0ZgYlhufh4gnc5dcfFC60%2BmErqdHDsI%2FFlUluEu475bKa%2BdYhqPAS4KK%2Fa2AoyfOiZn1THN0N0FKoX9tSTwd%2BBl74O2Npi7IJ%2FTQ8SiSYStNqzj3OfWuH%2FlXN65DSoHZrK5P%2FYd8CTwgr80HrkpAMVoKCzpnyNU1y%2BxOOU5WR%2FUe12qRANUEhf6C0Esao8CNhMqqbBCxALEltqcKFSQN0qI5LPtwIfyeDnwPwmZQwLWBvwJeEhl%2BhngSw%2BwJ4jWfgW3tJqcLLQuBBuWKgr7xjUk3KI8FIg4cBVwhfgvn1Wpoq00EBJhPyUeHQx8K%2ForB26Q1l2uyrNcOpXxZ8GGTyxpC2fLy7avAobCvs12SaK1lLl1%2BVzJsIoiWuA5wGfWvXa2r8w265XIuv5qVaKNkouLgW%2Bs5ZDJDYkqr68%2FoOo0VOOa19QaNxUB0rPLgXHy3MPAKn3%2BjUD05rmnTA%2FxKLBMJfUC78uVizK0WA8ccNRXN8orM0vkyjqJXi%2B7F%2FgytkeJdSQbqinKsxpOMHhY5rtGYJsDrNWTXHYMxjVn%2BI9Lm5yixClm2DRWZddfeJuAdQ6wRrV1VD%2BBNkiqoUQCOFHHWyxQB5hqwCjla9SGr3GUldt9i%2FfHZomahvs2vjBgaz3RumughO4CNjmKn3fykX4JNkYZfaLvs3PUaqQDjDebNb6bLgGe8OhpuUTqlH4CNWoz%2FDVtpI4vVaT6Kgcmk2avikjUJVM3FuLA05J8lf0EG8mKxxrc%2Fj3I5LZFD%2Fcq0GUMOL4DWZKneyzVq85hMsg9%2FrIAa4zVsK3Nk3vZA4gRamMj%2FLzmtdQdnspyANLJTF5uBv7oCdefyX4Qhg7jCJt3RM0txh9BnwD3ql043rZHI51lADYtbP5YytKFb2oSsuM4gtypMeeifJgO%2B7EhC%2BxbmkWtPw4g26UV3iiAJX%2FF8CUXGoLdD%2FxWneixtB5p2cc0jqRQi2KO%2BLOiJLZmppfqp5dJAeRfIevVhPlpr%2FJ4exVqTY5Yg9cts4RMjpq%2FSFO%2FSVJGxc7qExqerQLe9o0aMx1WpMUcsx9tvZsc61aO8yU6Ipp01PiIPanu9r%2BaSq%2FW4LfD32IevRt17SeV8D7SnngJ%2FAAAAABJRU5ErkJggg%3D%3D"> <img alt="Fedora" src="https://img.shields.io/badge/Fedora-c6c6d0?style=flat-square&labelColor=1e1f25&logo=fedora&logoColor=e3e1e9">

</div>

<img width="1920" height="1080" alt="screenshot_2026-11-15_22-49-02" src="https://github.com/user-attachments/assets/c4fce994-2ae4-46c2-9eff-497ec28b726d" />
<img width="1920" height="1080" alt="screenshot_2026-11-15_22-49-51" src="https://github.com/user-attachments/assets/ba1e4fd2-7b1c-4461-bda8-c45c429ef921" />
<img width="1910" height="1080" alt="screenshot_2026-11-28_12-54-41" src="https://github.com/user-attachments/assets/6c3ebb30-fcb7-4ea0-869d-1294e2c78d74" />
<img width="1920" height="1080" alt="screenshot_2026-11-28_12-53-41" src="https://github.com/user-attachments/assets/19d75799-7b4a-41e6-bfcc-5af9c79816e9" />

#### Starship prompt:
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/85941f10-70be-44ad-96eb-d799b2668999" />




## What's in it

Built on top of [niri](https://github.com/YaLTeR/niri) and [dux-shell](https://duxlabs.dev/), with my own configs and tweaks:

- **Custom Niri shaders & rules**: liquid-glass window open/close GLSL shaders, tuned blur and column proportions, and a dedicated Steam / Proton window ruleset
- **Shell & theming extras**: tuned DMS layout and keybinds, `gruvboxMulti` theme, `materialPlayer` & `screenCaptureToolbar` plugins, `dfiles` as the XDG file-picker portal, Darkly Qt/GTK setup, and a custom `matugen` template for `micro`
- **Terminal & shell**: Kitty with cursor trail and powerline tabs, Zsh + customized Starship prompt, custom Fastfetch logo, Yazi (`smart-enter`), and custom Cava shaders
- **Editors & media**: LazyVim (`nvim`), `micro`, `zed`, and `mpv` configured with `modernz`, `thumbfast`, and `mpv-anilist-updater`
- **Shared Proton for gaming**: optional `Proton-CachyOS Latest` installed once into Steam's `compatibilitytools.d` so both Steam and Lutris (via `umu`) share the same runner, with `.protonplus` metadata for ProtonPlus updates (prompted on normal install, automatic with `--me`)
- **Fonts & wallpapers**: bundled UI fonts (`Oxanium`, `Bodoni Moda`, `Roboto Flex`), `GoogleSansCode Nerd Font`, and curated wallpapers

## Install

On Fedora, clone and run `./install.sh` — it runs the official Dux shell installer (`install.duxlabs.dev`) if `dms` isn't installed yet, installs the companion CLI/desktop packages, links all configs and wallpapers (backing up any existing files to `~/.dotfiles-backup/`), and bootstraps Oh My Zsh, Nerd Fonts, and companion services:

```bash
git clone https://github.com/arprge/dankdots.git ~/dankdots
cd ~/dankdots
./install.sh
```

| Flag | Description |
|---|---|
| `./install.sh --dry-run` | preview every change without modifying anything |
| `./install.sh --me` | include personal `.gitconfig`, laptop display profile (`outputs.kdl`), and Lutris & ProtonPlus |
| `./install.sh zsh kitty niri` | install specific packages only |
| `./install.sh --sync` | pull live edits from `$HOME` back into the repo |
| `./install.sh --unlink` | remove symlinks and rendered files created by the installer |
| `./install.sh --uninstall` | unlink configs and restore the latest `~/.dotfiles-backup/` |

## Keys

| | |
|---|---|
| <kbd>Ctrl</kbd>+<kbd>Space</kbd> · <kbd>Alt</kbd>+<kbd>Space</kbd> | spotlight launcher · spotlight bar |
| <kbd>Super</kbd>+<kbd>T</kbd> | terminal (kitty) |
| <kbd>Ctrl</kbd>+<kbd>&#92;</kbd> · <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>&#92;</kbd> | yazi · dfiles file manager |
| <kbd>Super</kbd>+<kbd>O</kbd> · <kbd>Super</kbd>+<kbd>1</kbd>…<kbd>9</kbd> | overview · workspaces |
| <kbd>Super</kbd>+<kbd>Y</kbd> · <kbd>Super</kbd>+<kbd>,</kbd> | wallpapers · dux settings |
| <kbd>Super</kbd>+<kbd>N</kbd> · <kbd>Super</kbd>+<kbd>V</kbd> | notifications · clipboard |
| <kbd>Print</kbd> · <kbd>Super</kbd>+<kbd>Print</kbd> | screenshot · capture toolbar |
| <kbd>Super</kbd>+<kbd>Alt</kbd>+<kbd>L</kbd> · <kbd>Super</kbd>+<kbd>X</kbd> | lock screen · power menu |
| <kbd>Super</kbd>+<kbd>?</kbd> | keybind cheat sheet |

## Packages

`niri` · `dms` · `desktop` (`dsearch`, `dfiles`, `xdg-desktop-portal`) · `kitty` · `zsh` · `starship` · `nvim` · `micro` · `zed` · `yazi` · `fastfetch` · `btop` · `cava` · `mpv` · `matugen` · `theme` (GTK 3/4, Qt5ct/Qt6ct, Darkly) · `fonts` · `wallpapers` · `git` *(opt-in via `--me`)*

<sub>niri · dux shell · matugen · kitty · neovim · micro · yazi · adw-gtk3 · darkly · MIT license</sub>
