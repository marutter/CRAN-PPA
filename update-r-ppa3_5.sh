#!/bin/bash

# Script to automate build of r source packages for all supported Ubuntu
# releases to a launchpad ppa

# Author: Michael Rutter <marutter@gmail.com> based on scripts from
#         Vincent Goulet <vincent.goulet@act.ulaval.ca> and
#         Johannes Ranke <jranke@uni-bremen.de>

ChrootDir=/home/chroot
BuildDir=/usr/local/src/ppa
ScriptDir=/home/mrutter/R/PPA

packages=""
dist=""
number=0

usage="Usage: update-r-cran [options] [releases]

Build r-cran-* packages for each chroot jail specified in 'releases'.

-p MUST come before -r

Options:
  -h, --help		print short help message and exit
  -p, --packages        list of packages to build; defaults to the value
                        of the environment variable CRANPACKAGES
  -r, --releases        list of chroots for which to build packages;
                        defaults to the value of the environment variable
                        CRANRELEASE
  -n, --number		release number of the package (default 0)

The file .CRANenviron is sourced to possibly define the environment
variables CRANRELEASE and CRANPACKAGES.
"



if [ -e ${ScriptDir}/.CRANenviron ]
then
    . ${ScriptDir}/.CRANenviron
fi

# No arguments given. If the environment variables exist, use these
# values; otherwise, print usage information.
if [ $# -eq 0 ]
then
    if [ -n "${CRANRELEASE}" -a  -n "${CRANPACKAGES}" ]; then
	dist=${CRANRELEASE}
	packages=${CRANPACKAGES}
    else
	echo "${usage}"
	exit 0
    fi
fi



# At least one argument is provided. Could be the list of packages to
# build and/or the list of releases. Listing packages *requires* the
# -p flag. The -r flag is required only of the -p flag is given.
while test -n "${1}"; do
    case ${1} in
	-h|--help)
	    echo "${usage}"; exit 0
	    ;;
  	-p|--packages)
	    packages=""
	    until test "${2}" == "-r" -o "${2}" == "--releases" -o -z "${2}"; do
		packages=${packages}"${2} "
		shift
	    done
	    ;;
	-r|--releases)
	    dist=""
	    ;;
	 -n|--number)
	    shift
	    number="${1}"
	    ;;
	*)
	    dist=${dist}"${1} "
	    ;;
	 esac
    shift
done

echo schroot -p -c ${i} --directory ${BuildDir} "/usr/local/bin/build-r-ppa.sh ${packages} -n ${number}"

# There were arguments, but either of the list of packages or the list
# of releases may have not been given.
if [ -z "${dist}" ]
then
    if [ -n "${CRANRELEASE}" ]; then
	dist=${CRANRELEASE}
    else
	echo "Releases to build for unknown"
	exit 1
    fi
fi
if [ -z "${packages}" ]
then
    if [ -n "${CRANPACKAGES}" ]; then
	packages=${CRANPACKAGES}
    else
	echo "Packages to build unknown"
	exit 1
    fi
fi

# Check to see if package is not comptable with R 4.0

for p in ${packages}; do
  if [[ "$p" == "rodbc" ]]; then
    echo "rodbc not comptable with R < 4.0"
    exit 1
  fi
  if [[ "$p" == "foreign" ]]; then
    echo "foreign not comptable with R < 4.0"
    exit 1
  fi
done

echo "Building package(s): ${packages}"
echo "Ubuntu release(s): ${dist}"

for i in ${dist}; do
#    sudo schroot -p -c ${i} --directory ${BuildDir} /usr/local/bin/build-r-ppa.sh ${packages}-n ${number}
	sudo chroot /home/chroot/${i} usr/local/bin/build-r-ppa.sh ${packages} -n ${number}
    if [ $? -eq 0 ]; then
	echo "update-r-base.sh: build successful for ${i}, updating ppa"
	for p in ${packages}; do
	    cd ${ChrootDir}/${i}${BuildDir}/
	    p=`echo $p | sed 's/matrix/rmatrix/'` # non-standard name
#	    sudo dput ppa:marutter/rrutter ./*${p}*_source.changes
      until dput -U ppa:marutter/rrutter3.5 ./*${p}*_source.changes
       do
        echo "Didn't work, try again"
        sleep 1
       done
  done
    else
	echo "update-r-ppa.sh: build of one or more packages failed for ${i}"
	exit 1
    fi
done
