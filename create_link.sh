#! /usr/bin/env bash

CONFIGDIR="$(
  cd $(dirname .)
  pwd
)/config"
cd ${HOME}
for i in $(ls ${CONFIGDIR} | grep -v "runcom_"); do
  echo ${i} | fgrep -q "." && continue
  ln -s ${CONFIGDIR}/${i} .${i}
done
