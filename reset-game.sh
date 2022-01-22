#!/bin/bash

set -e

read -p "Are you sure you want to reset the game? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

APP_ID=com.github.avojak.warble
GSETTINGS_ID=$APP_ID
GSETTINGS_PATH=$APP_ID

print_setting () {
    echo -e "  $1 = $(flatpak run --command=gsettings $GSETTINGS_ID get $GSETTINGS_PATH $1)"
}

set_setting () {
    flatpak run --command=gsettings $GSETTINGS_ID set $GSETTINGS_PATH $1 "$2"
    print_setting $1
}

echo
echo "Resetting GSettings..."

set_setting first-launch true
set_setting difficulty 0
set_setting num-games-won 0
set_setting num-games-lost 0
set_setting win-streak 0
set_setting max-win-streak 0
set_setting guess-distribution "1:0|2:0|3:0|4:0|5:0|6:0"
set_setting is-game-in-progress false
set_setting answer ""
set_setting squares-state ""
set_setting keyboard-state ""
set_setting current-row 0
set_setting current-col 0
set_setting should-prompt-to-submit true
set_setting high-contrast-mode false

echo
echo -e "\033[1;32mDone\033[0m"
echo