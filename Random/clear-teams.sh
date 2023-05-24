#!/bin/bash

# This script cleans all cache for Microsoft Teams on Linux
# Tested on Ubuntu-like, Debian by @necrifede, Arch Linux by @lucas-dclrcq and Manjaro with flatpak by @danie1k. Feel free to test/use in other distributions.
# Tested Teams via snap package.
# Tested Teams via flatpak package.
#
# How to use in terminal:
# ./clear_cache_MS_Teams.sh ( deb-stable | deb-insider | snap | flatpak )
# or
# bash clear_cache_MS_Teams.sh ( deb-stable | deb-insider | snap | flatpak )

# Variable process name is defined on case statement.

case $1 in
  deb-stable)
    export TEAMS_PROCESS_NAME=teams
    cd "$HOME"/.config/Microsoft/Microsoft\ Teams || exit 1
  ;;
  deb-insider)
    export TEAMS_PROCESS_NAME=teams-insiders
    cd "$HOME"/.config/Microsoft/Microsoft\ Teams\ -\ Insiders || exit 1
  ;;
  snap)
    export TEAMS_PROCESS_NAME=teams
    cd "$HOME"/snap/teams/current/.config/Microsoft/Microsoft\ Teams || exit 1
  ;;
  flatpak)
    export TEAMS_PROCESS=teams
    cd "$HOME"/.var/app/com.microsoft.Teams/config/Microsoft/Microsoft\ Teams || exit 1
  ;;
  *)
    echo "Use $0 ( deb-stable | deb-insider | snap | flatpak ) as parameter."
    exit 1
  ;;
esac

# Test if Microsoft Teams is running
if [ "$(pgrep ${TEAMS_PROCESS_NAME} | wc -l)" -gt 1 ]
then
  rm -rf Application\ Cache/Cache/*
  rm -rf blob_storage/*
  rm -rf Cache/* # Main cache
  rm -rf Code\ Cache/js/*
  rm -rf databases/*
  rm -rf GPUCache/*
  rm -rf IndexedDB/*
  rm -rf Local\ Storage/*
  #rm -rf backgrounds/* # Background function presents on Teams for Windows only.
  find ./ -maxdepth 1 -type f -name "*log*" -exec rm {} \;
  sleep 5
  killall ${TEAMS_PROCESS_NAME}
  # After this, MS Teams will open again.
else
  echo "Microsoft Teams is not running."
  exit
fi