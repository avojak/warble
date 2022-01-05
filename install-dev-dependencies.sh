#!/bin/bash

flatpak remote-add --if-not-exists --system appcenter https://flatpak.elementary.io/repo.flatpakrepo
flatpak install -y appcenter io.elementary.Platform io.elementary.Sdk