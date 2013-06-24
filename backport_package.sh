#!/bin/bash
#https://launchpad.net/ubuntu/+source/foo for links
export DEBFULLNAME="Michael Rutter"
export DEBEMAIL="Michael Rutter <marutter@gmail.com>"
PKG=https://launchpad.net/~marutter/+archive/c2d4u/+files/rquantlib_0.3.10-1precise0.dsc
#backportpackage -y -u ppa:marutter/c2d4u -d oneiric $PKG
#backportpackage -y -u ppa:marutter/c2d4u -d precise $PKG
backportpackage -y -u ppa:marutter/c2d4u -d quantal $PKG
