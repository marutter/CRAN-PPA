#!/bin/bash

# Script to build r-cran-* packages for the Ubuntu release specified
# in file /etc/lsb-release. This script should be run as root, in one way or another.
# Designed to upload source packages to rrutter PPA.

# Author: Michael Rutter <marutter@gmail.com> based on scripts from 
#         Vincent Goulet <vincent.goulet@act.ulaval.ca> and
#         Johannes Ranke <jranke@uni-bremen.de>

export DEBEMAIL="Michael Rutter <marutter@gmail.com>"

cat bionic_order_test.csv | while read line
do
  cd /usr/local/src/c2d4u3.5
  apt-get source --only-source $line
  cd *$line-*
  dch -D "bionic" "Rebuild for R 3.5.0 on c2d4u3.5"
  debuild --no-tgz-check -S -sa -d
  cd ..
  dput --unchecked ppa:marutter/c2d4u3.5 ./*${line}*_source.changes
  #rm -fr *
  cd /usr/local/bin
  sleep 5s
done

cd /usr/local/src/c2d4u3.5
rm -fr *
cd /usr/local/bin
 
