#!/bin/bash

# Script to build r-cran-* packages for the Ubuntu release specified
# in file /etc/lsb-release. This script should be run as root, in one way or another.
# Designed to upload source packages to rrutter PPA.

# Author: Michael Rutter <marutter@gmail.com> based on scripts from 
#         Vincent Goulet <vincent.goulet@act.ulaval.ca> and
#         Johannes Ranke <jranke@uni-bremen.de>

export DEBEMAIL="Michael Rutter <marutter@gmail.com>"
export PATH=/usr/lib/kde4/bin:$PATH # to build rkward

cd /usr/local/src/ppa

if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
else
    echo "Cannot find /etc/lsb-release to determine Ubuntu release"
    exit 1
fi

if [ $# -eq 0 ]
then
    if [ -n "${CRANPACKAGES}" ]; then
	packages=${CRANPACKAGES}
    else
	echo "Packages to build unknown"
	exit 1
    fi
fi

number=0

while test -n "${1}"; do
    case ${1} in
	-p|--packages)
	    packages=""
	    ;;
	-n|--number)
	    shift
	    number="${1}"
	    ;;
	*)
	    packages=${packages}"${1} " 
	 ;;
    esac
    shift
done

echo "Build number: " ${number}

## The Debian source package for Matrix has the non-standard name
## 'rmatrix'. It is expected, however, that users of the scripts will
## use the simpler name 'matrix'. We need to make the change here.
packages=`echo $packages | sed 's/matrix/rmatrix/'`

## Similarly, the Debian source packages for class, mass, nnet and
## spatial (formerly in vr) have the non-standard names
## 'r-cran-[foo]'. It is expected, however, that users of the scripts
## will use the simpler names.
packages=`echo $packages | sed 's/class/r-cran-class/'`
packages=`echo $packages | sed 's/mass/r-cran-mass/'`
packages=`echo $packages | sed 's/nnet/r-cran-nnet/'`
packages=`echo $packages | sed 's/spatial/r-cran-spatial/'`

echo $packages

apt-get update
for i in ${packages}; do
    rm -rf *${i/rmatrix/matrix}*
      apt-get source --only-source $i/unstable
##    apt-get source $i
    cd $i-*
	
	# Add new version to changelog
    version=`dpkg-parsechangelog | grep ^Version | cut -f2 -d " "`"${DISTRIB_CODENAME}${number}"
    dch -v "${version}" -D "${DISTRIB_CODENAME}" "Compilation for ${DISTRIB_DESCRIPTION}"
	
	if [[ ${i} == "rjags" ]]
    then
      version=${version/-/.}
    fi
	
	
	if [ ${i} == "rpy" ]
	then
		sed -i '/^Build-Depends/s/debhelper (>= 7.2.17)/debhelper/' debian/control
		dch -a "debian/control, debian/rules, debian/compat: revert to a version of debheler < 7.0.0"
				sed -i '/^Depends/s/dpkg (>= 1.15.4)/dpkg/' debian/control
		dch -a "dpkg: revert to a version of dpkg < 7.0.0"
		sed -i '/^Build-Depends/s/python-numpy (>= 1:1.3.0)/python-numpy/' debian/control
		sed -i '/^Depends/s/python-numpy (>= 1:1.3.0)/python-numpy/' debian/control
		dch -a "debian/control, debian/rules, debian/compat: revert to a version of python-numpy < 1.3.0"
		sed -i '/^Build-Depends/s/python-all-dev (>= 2.6.6-3)/python-all-dev/' debian/control
		dch -a "debian/control, debian/rules, debian/compat: revert to a version of python-all-dev < 2.6.6-3"

	fi
	if [ ${i} == "rpy2" ]
	then
		sed -i '/^Build-Depends/s/python-all-dev (>= 2.6.6-3)/python-all-dev/' debian/control
		dch -a "debian/control, debian/rules, debian/compat: revert to a version of python-all-dev < 2.6.6-3"
	fi
	if [[ ${DISTRIB_CODENAME} == "lucid" &&${i} == "rpy2" ]]
	then
		sed -i 's/dh_python2/dh_pysupport/g' debian/rules
		dch -a "debian/rules: Convert dh_pyhton2 to dh_pysupport"
	fi
	if [[ ${DISTRIB_CODENAME} == "karmic" && ${i} == "jags" ]]
	then
		sed -i '/^Build-Depends/s/libltdl-dev (>= 2.2.6b)/libltdl-dev/' debian/control
		dch -a "debian/control, debian/rules, debian/compat: revert to a version of libltdl-dev < 2.2.6b"
	fi
	if [[ ${DISTRIB_CODENAME} == "hardy" && ${i} == "jags" ]]
	then
		sed -i '/^Build-Depends/s/libltdl-dev (>= 2.2.6b)/libltdl3-dev/' debian/control
		dch -a "debian/control, debian/rules, debian/compat: revert to a version of libltdl3-dev"
		sed -i '/^Build-Depends/s/debhelper (>= 7.0.50~)/debhelper/' debian/control
		dch -a "debian/control, debian/rules, debian/compat: revert to a version of debheler < 7.0.0"
	fi
    if [[ ${DISTRIB_CODENAME} < "karmic" ]]
        then
        sed -i '/^Depends/s/dpkg (>= 1.15.4) | install-info/dpkg | install-info/' debian/control
        dch -a "debian/control: revert Depends: to 'dpkg | install-info' since ${DISTRIB_DESCRIPTION} has a version of dpkg < 1.15.4 and no separate package i\
nstall-info"
    fi
	if [ ${i} == "rjava" ]
	then
		cd debian
        wget http://192.168.1.129/rjava/postinst
        chmod +x ./postinst
        cd ..
		dch -a "postinst: Added post install script to reconfigure java in R"
	fi
	if [ ${DISTRIB_CODENAME} == "lucid" && ${i} == "rjava" ]
	then
		sed -i '/^Build-Depends/s/libgcj12-dev/libgcj10-dev/' debian/control
		dch -a "Adjust libgcj from 12 to 10 for lucid"
	fi
	
#    dpkg-checkbuilddeps
    if [ $? -ne 0 ]; then
	exit 1
    fi
    debuild --no-tgz-check -S -sa
#    debuild -S -us -uc
#    dpkg-buildpackage -tc -uc -us
    if [ $? -ne 0 ]; then
	exit 1
    fi
    cd ..
    #i=`echo $i | sed 's/rmatrix/matrix/'` # non-standard name
    #dput ppa:marutter/rrutter ./*$i*.changes
done
