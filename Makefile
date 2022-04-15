SHELL := /bin/bash

APP_ID := com.github.avojak.warble

BUILD_DIR        := build
NINJA_BUILD_FILE := $(BUILD_DIR)/build.ninja

.PHONY: all flatpak flathub lint translations clean
.DEFAULT_GOAL := flatpak

all: translations flatpak

init:
	flatpak remote-add --if-not-exists --system appcenter https://flatpak.elementary.io/repo.flatpakrepo
	flatpak install -y appcenter io.elementary.Platform//6.1 io.elementary.Sdk//6.1

flatpak:
	flatpak-builder build $(APP_ID).yml --user --install --force-clean

flathub-init:
	flatpak remote-add --if-not-exists --system flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install -y flathub org.gnome.Platform//42 org.gnome.Sdk//42

flathub:
	flatpak-builder build flathub/$(APP_ID).yml --user --install --force-clean

lint:
	io.elementary.vala-lint ./src

$(NINJA_BUILD_FILE):
	meson build --prefix=/user

translations: $(NINJA_BUILD_FILE)
	ninja -C build $(APP_ID)-pot
	ninja -C build $(APP_ID)-update-po

clean:
	rm -rf build/
	rm -rf builddir/
	rm -rf .flatpak-builder/