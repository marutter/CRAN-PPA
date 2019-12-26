#!/bin/bash

sudo cp build-r-ppa.sh /home/chroot/trusty/usr/local/bin/
sudo cp build-r-ppa.sh /home/chroot/xenial/usr/local/bin/
sudo cp build-r-ppa.sh /home/chroot/zesty/usr/local/bin/
sudo cp build-r-ppa.sh /home/chroot/artful/usr/local/bin/

sudo cp build-r-base-ppa.sh /home/chroot/trusty/usr/local/bin/
sudo cp build-r-base-ppa.sh /home/chroot/xenial/usr/local/bin/
sudo cp build-r-base-ppa.sh /home/chroot/artful/usr/local/bin/



sudo cp build-r-base-ppa.sh /home/chroot/precise/usr/local/bin/build-r-base-devel.sh
sudo sed -i 's/cd \/usr\/local\/src\/ppa/cd \/usr\/local\/src\/devel/g' /home/chroot/precise/usr/local/bin/build-r-base-devel.sh
sudo cp build-r-base-ppa.sh /home/chroot/trusty/usr/local/bin/build-r-base-devel.sh
sudo sed -i 's/cd \/usr\/local\/src\/ppa/cd \/usr\/local\/src\/devel/g' /home/chroot/trusty/usr/local/bin/build-r-base-devel.sh
sudo cp build-r-base-ppa.sh /home/chroot/xenial/usr/local/bin/build-r-base-devel.sh
sudo sed -i 's/cd \/usr\/local\/src\/ppa/cd \/usr\/local\/src\/devel/g' /home/chroot/xenial/usr/local/bin/build-r-base-devel.sh
sudo cp build-r-base-ppa.sh /home/chroot/zesty/usr/local/bin/build-r-base-devel.sh
sudo sed -i 's/cd \/usr\/local\/src\/ppa/cd \/usr\/local\/src\/devel/g' /home/chroot/zesty/usr/local/bin/build-r-base-devel.sh
