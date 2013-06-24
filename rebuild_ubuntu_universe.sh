#!/bin/bash
while read p; do
  echo $p
  ./update-r-ppa.sh -r quantal precise lucid -p ${p} -n 3
done < "./ubuntu_r_packages.txt"
