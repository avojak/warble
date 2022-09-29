![CI](https://github.com/avojak/warble/workflows/CI/badge.svg)
![Lint](https://github.com/avojak/warble/workflows/Lint/badge.svg)
![GitHub](https://img.shields.io/github/license/avojak/warble.svg?color=blue)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/avojak/warble?sort=semver)

<p align="center">
  <img src="data/assets/warble.svg" alt="Icon" />
</p>
<h1 align="center">Warble</h1>
<p align="center">
  <a href="https://appcenter.elementary.io/com.github.avojak.warble"><img src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter" /></a>
  <a href='https://flathub.org/apps/details/com.github.avojak.warble'><img width='155' alt='Download on Flathub' src='https://flathub.org/assets/badges/flathub-badge-en.png'/></a>
</p>

| ![Screenshot](data/assets/screenshots/warble-screenshot-01.png) | ![Screenshot](data/assets/screenshots/warble-screenshot-02.png) | ![Screenshot](data/assets/screenshots/warble-screenshot-03.png) | ![Screenshot](data/assets/screenshots/warble-screenshot-04.png) |
|------------------------------------------------------------------|------------------------------------------------------------------|------------------------------------------------------------------|------------------------------------------------------------------|

## The word-guessing game

Warble is a native Linux word-guessing game built in Vala and Gtk for [elementary OS](https://elementary.io).

Figure out the word before your guesses run out!
- Three difficulty levels
- Almost 5k possible answers
- Need a break? Close the game and automatically pick back up where you left off

<p align="center"><img src="./data/assets/BCD631EA-53B9-483E-9C75-CB00C1E33C52.jpeg" width="500"></p>

Warble is inspired by (and not affiliated with) the recently popular online game Wordle (which itself is reminiscent of the late 80's game show Lingo). 

## Installation

If you are not on elementary OS, you can install Warble from Flathub:

```bash
$ flatpak install flathub com.github.avojak.warble
```

### Community Packages

The officially supported method of installing Warble is via the flatpak, however there are several other packages maintained by the community for support on other platforms:

| Source | Channel/Branch | Version |
| ------ | -------------- | ------- |
| Snapcraft | `stable` | <a href="https://snapcraft.io/warble"><img src="https://badgennet-git-fork-vladimyr-snapcraft-badgen.vercel.app/snapcraft/v/warble/arm64/stable"></img></a> |
| | `edge` | <a href="https://snapcraft.io/warble"><img src="https://badgennet-git-fork-vladimyr-snapcraft-badgen.vercel.app/snapcraft/v/warble/arm64/edge"></img></a> |
| Fedora | `rawhide` | [![Fedora Rawhide](https://repology.org/badge/version-for-repo/fedora_rawhide/warble.svg?header=Fedora%20Rawhide)](https://repology.org/project/warble/versions) |
|  | `f37` | [![Fedora 37](https://repology.org/badge/version-for-repo/fedora_37/warble.svg?header=Fedora%2037)](https://repology.org/project/warble/versions) |
|  | `f36` | [![Fedora 36](https://repology.org/badge/version-for-repo/fedora_36/warble.svg?header=Fedora%2036)](https://repology.org/project/warble/versions) |
|  | `f35` | [![Fedora 35](https://repology.org/badge/version-for-repo/fedora_35/warble.svg?header=Fedora%2035)](https://repology.org/project/warble/versions) |
| AUR |  | [![AUR package](https://repology.org/badge/version-for-repo/aur/warble.svg?header=AUR)](https://repology.org/project/warble/versions) |

## Install from Source

You can install Warble by compiling from source using `flatpak-builder`:

```bash
$ flatpak-builder build com.github.avojak.warble.yml --user --install --force-clean
$ flatpak run --env=G_MESSAGES_DEBUG=all com.github.avojak.warble
```

Another helpful environment variable to set is `GTK_DEBUG=interactive` for investigating UI and styling issues.

## Word List

The `dictionary.txt` word list is sourced from [sindresorhus/word-list](https://github.com/sindresorhus/word-list).

## Project Status

This project is very much in-progress and has a lot of remaining work. Check out the [Projects](https://github.com/avojak/warble/projects) page to track progress towards the next milestone.

Please keep in mind that at this time I am developing Warble as a personal project in my limited free time to learn Vala and contribute back to the [elementary OS](https://elementary.io) community, so do not be offended if I reject a pull request or other contribution.

<p align="center"><a href="https://www.buymeacoffee.com/avojak" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a></p>
