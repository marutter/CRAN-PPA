#!/bin/bash

export DEBEMAIL="Michael Rutter <marutter@gmail.com>"
export DEBFULLNAME="Michael Rutter"

backportpackage -y -u ppa:marutter/c2d4u3.5 -d bionic ${1}
