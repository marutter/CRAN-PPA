#!/bin/bash

# Script to automate build of r base source packages for all supported Ubuntu
# releases to a launchpad ppa

# Author: Michael Rutter <marutter@gmail.com> based on scripts from 
#         Vincent Goulet <vincent.goulet@act.ulaval.ca> and
#         Johannes Ranke <jranke@uni-bremen.de>

ChrootDir=/home/chroot
BuildDir=/usr/local/src/ppa

dist=""

usage="Usage: update-r-base [options] [releases]

Build r-base packages for each chroot jail specified in 'releases'.

Options:
  -h, --help		print short help message and exit
  -n, --number		release number of the package (default 0)
  -r, --releases        list of chroots for which to build packages; 
                        defaults to the value of the environment variable 
                        CRANRELEASE

The file ~/.CRANenviron is sourced to possibly define the environment
variable CRANRELEASE.

Usage of the -r flag is required if, and only if, the -n flag is used
and 'releases' is not empty.
"

if [ -e ${HOME}/.CRANenviron ]
then
    . ${HOME}/.CRANenviron
fi

# If the environment variable CRANRELEASE exists, use it to define the
# list of releases to build for.
if [ -n "${CRANRELEASE}" ]
then
    dist=${CRANRELEASE}
fi

# No arguments given. Use default arguments of, if the list of
# releases is empty, print usage information.
if [ $# -eq 0 ]
then
    number=0
    if [ -z "${dist}" ]; then
	echo "${usage}"
	exit 0
    fi
fi

# At least one argument is provided. Could be the revision number
# and/or the list of releases. The -r flag is required only if the -n
# flag is given.
while test -n "${1}"; do
    case ${1} in
	-h|--help)
	    echo "${usage}"; exit 0 
	    ;;
	-n|--number)
	    shift
	    number="${1}"
	    ;;
	-r|--releases)
	    dist=""
	    ;;
	*)
	    dist=${dist}"${1} " 
	 ;;
    esac
    shift
done


# Small function to kill rogue Xvfb processes
function killxvfb {
    pid=`pidof Xvfb`
    if [ $pid ]; then
	sudo kill -9 $pid
    fi
}


echo "Building r-base for Ubuntu releases ${dist}"
echo "Release number: ${number}"

for i in ${dist}; do
#    sudo schroot -p -c ${i} --directory ${BuildDir} /usr/local/bin/build-r-ppa.sh ${packages}-n ${number}
	sudo chroot /home/chroot/${i} /usr/local/bin/build-r-base-ppa.sh -n ${number}
    if [ $? -eq 0 ]; then
	echo "update-r-base.sh: build successful for ${i}, updating ppa"
	cd ${ChrootDir}/${i}${BuildDir}/
	sudo dput ppa:marutter/rrutter ./*r-base*_source.changes
    else
	echo "update-r-ppa.sh: build of one or more packages failed for ${i}"
	exit 1
    fi
done
