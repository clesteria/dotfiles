#! /usr/bin/env bash

find ${HOME} -maxdepth 1 -type l -exec ls -lad {} \; | awk '/dotfiles/ { print $9 }' | xargs rm

