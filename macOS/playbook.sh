#!/usr/bin/env bash

cd $(dirname $0)

export ansible_python_interpreter="$(which python3)"

ansible-playbook -i production macosx.yml
