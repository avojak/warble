# Warble

Warble is a native Linux desktop application built in Vala and GTK for [elementary OS](https://elementary.io).

## Install from Source

You can install Warble by compiling from source. Here's the list of
dependencies required:

- `granite (>= 0.6.0)`
- `debhelper (>= 10.5.1)`
- `gettext`
- `libgtk-3-dev (>= 3.10)`
- `meson`
- `valac (>= 0.28.0)`

An `install-dev-dependencies.sh` script is available to help developers get up and running.

## Building and Running

```
$ meson build --prefix=/usr
$ sudo ninja -C build install
$ com.github.avojak.warble
```

### Flatpak

To test the Flatpak build with Flatpak Builder:

```bash
$ flatpak-builder build com.github.avojak.warble.yml --user --install --force-clean
$ flatpak run --env=G_MESSAGES_DEBUG=all com.github.avojak.warble
```

### Updating Translations

When new translatable strings are added, ensure that `po/POTFILES` contains a
reference to the file with the translatable string.

Update the `.pot` file which contains the translatable strings:

```
$ ninja -C build com.github.avojak.warble-pot
```

Generate translations for the languages listed in the `po/LINGUAS` files:

```
$ ninja -C build com.github.avojak.warble-update-po
```

## Word List

The `dictionary.txt` word list is sourced from [sindresorhus/word-list](https://github.com/sindresorhus/word-list)