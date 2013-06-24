#!/bin/bash

sudo cp build-r-ppa.sh /home/chroot/hardy/usr/local/bin/
sudo sed -i 's/apt-get source --only-source $i\/unstable/apt-get source $i/g' /home/chroot/hardy/usr/local/bin/build-r-ppa.sh
sudo cp build-r-ppa.sh /home/chroot/lucid/usr/local/bin/
sudo cp build-r-ppa.sh /home/chroot/oneiric/usr/local/bin/
sudo cp build-r-ppa.sh /home/chroot/precise/usr/local/bin/
sudo cp build-r-ppa.sh /home/chroot/quantal/usr/local/bin/
sudo cp build-r-ppa.sh /home/chroot/raring/usr/local/bin/

sudo cp build-r-base-ppa.sh /home/chroot/hardy/usr/local/bin/
sudo sed -i 's/dch -v "${version}"/dch -D hardy -v "${version}"/g' /home/chroot/hardy/usr/local/bin/build-r-base-ppa.sh
sudo cp build-r-base-ppa.sh /home/chroot/lucid/usr/local/bin/
sudo cp build-r-base-ppa.sh /home/chroot/oneiric/usr/local/bin/
sudo cp build-r-base-ppa.sh /home/chroot/precise/usr/local/bin/
sudo cp build-r-base-ppa.sh /home/chroot/quantal/usr/local/bin/
sudo cp build-r-base-ppa.sh /home/chroot/raring/usr/local/bin/

sudo cp build-r-base-ppa.sh /home/chroot/lucid/usr/local/bin/build-r-base-devel.sh
sudo sed -i 's/cd \/usr\/local\/src\/ppa/cd \/usr\/local\/src\/devel/g' /home/chroot/lucid/usr/local/bin/build-r-base-devel.sh
sudo cp build-r-base-ppa.sh /home/chroot/precise/usr/local/bin/build-r-base-devel.sh
sudo sed -i 's/cd \/usr\/local\/src\/ppa/cd \/usr\/local\/src\/devel/g' /home/chroot/precise/usr/local/bin/build-r-base-devel.sh
sudo cp build-r-base-ppa.sh /home/chroot/quantal/usr/local/bin/build-r-base-devel.sh
sudo sed -i 's/cd \/usr\/local\/src\/ppa/cd \/usr\/local\/src\/devel/g' /home/chroot/quantal/usr/local/bin/build-r-base-devel.sh
sudo cp build-r-base-ppa.sh /home/chroot/raring/usr/local/bin/build-r-base-devel.sh
sudo sed -i 's/cd \/usr\/local\/src\/ppa/cd \/usr\/local\/src\/devel/g' /home/chroot/raring/usr/local/bin/build-r-base-devel.sh
