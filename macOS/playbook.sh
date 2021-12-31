#!/usr/bin/env bash

cd $(dirname $0)

ansible-playbook -i production macosx.yml

