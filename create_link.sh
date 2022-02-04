#! /usr/bin/env bash

CONFIGDIR="$(cd $(dirname .); pwd)/config"
cd ${HOME}
for i in $(ls ${CONFIGDIR}); do
  echo ${i} | fgrep -q "." && continue
  ln -s ${CONFIGDIR}/${i} .${i}
done
