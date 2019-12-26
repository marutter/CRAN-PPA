#!/bin/bash

# Script to build r-base packages for the Ubuntu release specified
# in file /etc/lsb-release. This script should be run as root, in one way or another.
# Designed to upload source packages to rrutter PPA.

# Author: Michael Rutter <marutter@gmail.com> based on scripts from 
#         Vincent Goulet <vincent.goulet@act.ulaval.ca> and
#         Johannes Ranke <jranke@uni-bremen.de>

export DEBEMAIL="Michael Rutter <marutter@gmail.com>"

cd /usr/local/src/ppa

if [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
else
    echo "Cannot find /etc/lsb-release to determine Ubuntu release"
    exit 1
fi

if [ $# -eq 0 ]
then
    number=0
else
    while test -n "${1}"; do
	case ${1} in
	    -n|--number)
		shift
		number="${1}"
		;;
	esac
	shift
    done
fi

rm -rf r-base* r-doc* r-mathlib* r-recommended*

apt-get update
apt-get -y --force-yes upgrade
apt-get source r-base

# Change any ~ in the name of the build directory for a - to avoid a
# bug in texi2dvi.
if [ -d r-base-*~* ]
then
    dir=`ls -d r-base-*~*`
    mv $dir `echo $dir | sed y/~/-/`
fi



cd r-base-*

# Add new version to changelog
version=`dpkg-parsechangelog | grep ^Version | cut -f2 -d " "`"${DISTRIB_CODENAME}${number}"
dch -v "${version}"  -D "${DISTRIB_CODENAME}" "Compilation for ${DISTRIB_DESCRIPTION}"

echo ${version}
echo "Compilation for ${DISTRIB_DESCRIPTION}"

sed -i '/^Build-Depends/s/tk8.6-dev/tk-dev/' debian/control
sed -i '/^Build-Depends/s/tcl8.6-dev/tcl-dev/' debian/control
dch -a "debian/control Changed dependency to generic tcl-dev and tk-dev"

if [[ ${DISTRIB_CODENAME} > "precise" ]]
then
	sed -i '/^Provides/s/r-api-3.4/r-api-3/' debian/control
	dch -a "Revert provides to r-api-3"
fi

if [[ ${DISTRIB_CODENAME} == "xenial" ]]
then
    sed -i '/^Build-Depends/s/openjdk-9-jdk | default-jdk/default-jdk/' debian/control
    dch -a "debian/control: Use default-jdk"
fi

#dch -a "debian/rules: Added configure option to not use OpenMP, ensuring compatability with some multithreaded packages in Ubuntu"
#sed -i '
#/--without-recommended-packages/ a\
#		    --disable-openmp 	\\' debian/rules

# Reverts in Ubuntu releases <= Gutsy:
#
# 1. Starting with Debian packages for R 2.6.1-2, the build dependency
#    to 'refblas3-dev|atlas3-base-dev' is changed to 'libblas-dev' to
#    use the new gfortran-built BLAS libraries. From R 2.7.0, the
#    dependency is on 'libblas-dev | libatlas-base-dev' for
#    r-base-dev.
#
# 2. Starting with Debian packages for R 2.6.2, new build dependency
#    on liblapack-dev to switch back to using Debian's Lapack rather
#    than the version supplied by R. From R 2.7.0, the dependency is
#    on 'liblapack-dev (>= 3.1.1)' for r-base and 'liblapack-dev |
#    libatlas-base-dev' for r-base-dev.
#
# 3. Requirement for tk8.4 >= 8.4.16-2 introduced in r-base 2.6.0-4 to
#    circumvent a breakage with 8.4.16-1. (The versions in Ubuntu are
#    <= 8.4.15-1.)
#
# 4. Starting with Debian packages for R 2.9.1, the xpdf-reader build
#    dependency is changed to xdg-utils, which is present in Ubuntu
#    starting only with Hardy.
#if [[ ${DISTRIB_CODENAME} < "hardy" ]]
#then
    #sed -i '/^Build-Depends/s/libblas-dev/refblas3-dev|atlas3-base-dev/' debian/control
    #sed -i '/^Depends/s/libblas-dev | libatlas-base-dev/refblas3-dev|atlas3-base-dev/' debian/control
    #dch -a "debian/control: revert Build-Depends: to 'refblas3-dev|atlas3-base-dev' and Depends: to 'refblas3-dev|atlas3-base-dev' since Ubuntu does not have the new gfortran-built BLAS libraries"
    #sed -i '/^Build-Depends/s/liblapack-dev (>= 3.1.1), //' debian/control
    #sed -i '/^Depends/s/liblapack-dev | libatlas-base-dev, //' debian/control
    #dch -a "debian/control: revert Build-Depends: and Depends: fields since Ubuntu uses the Lapack supplied with R"
    #sed -i '/^lapack/{
#s/lapack/\#lapack/
#a\
## vg 10 Apr 2008 Set to =no for Ubuntu <= Gutsy
#a\lapack		= --with-lapack=no
#}'  debian/rules
    #dch -a "debian/rules: ditto, do not configure --with-lapack"
    #rm debian/shlibs.local
    #dch -a "delete debian/shlibs.local since the dependency on tk8.4 is not an issue in Ubuntu releases prior to Hardy"
    #sed -i '/^Build-Depends/s/xdg-utils/xpdf-reader/' debian/control
    #dch -a "debian/control: revert Build-Depends: to 'xpdf-reader' since this version of Ubuntu does not have 'xdg-utils'"
#fi

# Reverts in Ubuntu releases <= Feisty:
#
# 1. Build-Depends on "tcl8.5-dev, tk8.5-dev" to "tcl8.4-dev,
#    tk8.4-dev" since this is the only version available on Dapper and
#    Feisty. On Gutsy, the 8.5 versions are available from the
#    backports repository.
#if [[ ${DISTRIB_CODENAME} < "gutsy" ]]
#then
    #sed -i '/^Build-Depends/s/tcl8.5-dev, tk8.5-dev/tcl8.4-dev, tk8.4-dev/' debian/control
    #dch -a "debian/control: revert Build-Depends: to 'tcl8.4-dev, tk8.4-dev' since Tcl/Tk 8.5 is not available on this release of Ubuntu."
#fi

# Reverts in Ubuntu release == Dapper:
#
# 1. The version of dpkg-gencontrol does not support the
#    ${binary:Version} and ${source:Version} variables.
#
# 2. Debian packages depend on {gcc,g++,gfortran} >= 4.1.0
#    starting from R 2.6.0. Reverted to >= 4.0.3.
#
# 3. The TeX distribution is still tetex, not texlive.
#
# 4. Command ucfr is not in package ucf. Requires manual copying of
#    one file.
#if [[ ${DISTRIB_CODENAME} == "dapper" ]]
#then
    #sed -i 's/{binary:Version}/{Source-Version}/g' debian/control
    #sed -i 's/{source:Version}/{Source-Version}/g' debian/control
    #dch -a "debian/control: reverted variables $source:Version and $binary:version to $Source-Version as the former are not supported in the Dapper version of dpkg-gencontrol."
    #sed -i '/^Build-Depends/s/gcc (>= 4:4.1.0)/gcc (>= 4:4.0.3)/' debian/control
    #sed -i '/^Build-Depends/s/g++ (>= 4:4.1.0)/g++ (>= 4:4.0.3)/' debian/control
    #sed -i '/^Build-Depends/s/gfortran (>= 4:4.1.0)/gfortran (>= 4.0.3)/' debian/control
    #dch -a "debian/control: backport Build-Depends: to {gcc,g++,gfortran} >= 4:4.0.3 instead of >= 4:4.1.0"
    #sed -i '/^Build-Depends/s/texlive-base, texlive-latex-base, texlive-generic-recommended, texlive-fonts-recommended, texlive-extra-utils, texlive-latex-recommended, texlive-latex-extra, texinfo, texi2html/tetex-bin, tetex-extra/' debian/control
    #dch -a "debian/control: revert Build-Depends: to 'tetex-bin, tetex-extra' since Dapper does not have texlive"
    #sed -i '/^    ucf /a\    # vg 24 Jun 2008   ucfr is not in Dapper; need to copy one file manually' debian/r-base-core.postinst
    #sed -i '/^    ucfr/{
#s/ucfr/\#ucfr/
#a\    cp /usr/lib/R/etc/Renviron.ucf /etc/R/Renviron
#}' debian/r-base-core.postinst
    #dch -a "debian/r-base-core.postinst: remove call to ucfr since the command does not exist in Dapper and copy the system Renviron file to /etc/R manually"
#fi

#if [[ ${DISTRIB_CODENAME} == "hardy" ]]
#then
    #sed -i '/^Build-Depends/s/default-jdk/openjdk-6-jdk/' debian/control
    #dch -a "debian/control: Use openjdk-6-jdk instead of default-jdk"
#fi

# For <= Jaunty
# Need to move some r-doc-{info,html}.{postinst,prerm} from older build into
# 2.9.2+ due to new version of dpkg causes these files to be automatically registered.
# Downloaded from Michael Rutter's website.
# Also returns debhelper Build-Depends to pre 2.9.2 requirements.
# Dapper must have debhelper (>=5.0.0), so be careful.
#if [[ ${DISTRIB_CODENAME} < "karmic" ]]
#then
    #cd debian
    #wget math.bd.psu.edu/faculty/rutter/R/r-doc-html.prerm
    #wget math.bd.psu.edu/faculty/rutter/R/r-doc-html.postinst
    #wget math.bd.psu.edu/faculty/rutter/R/r-doc-info.prerm
    #wget math.bd.psu.edu/faculty/rutter/R/r-doc-info.postinst
    #cd ..
    #sed -i '/^Build-Depends/s/debhelper (>= 7.2.3)/debhelper/' debian/control
    #dch -a "debian/control: revert Build-Depends: to 'debhelper' since ${DISTRIB_DESCRIPTION} has a version < 7.2.3"
    #sed -i 's/dh_prep/dh_clean/g' debian/rules
    #dch -a "debian/rules: revert dh_prep calls to dh_clean calls since the latter is not present in this release's version of 'debhelper'"
    #sed -i '/^Depends/s/dpkg (>= 1.15.4) | install-info/dpkg | install-info/' debian/control
    #dch -a "debian/control: revert Depends: to 'dpkg | install-info' for r-doc-info since ${DISTRIB_DESCRIPTION} has a version of dpkg < 1.15.4 and no separate package install-info"
    #sed -i '/^Build-Depends/s/liblzma-dev//' debian/control
    #dch -a "debian/control: removed Depends: liblzma-dev since liblzma-dev is not available in ${DISTRIB_DESCRIPTION}"
    #sed -i '/^Build-Depends/s/tk8.5-dev,/tk8.5-dev, libxss-dev,/' debian/control
    #dch -a "debian/control: added Depends: libxss-dev since libxss-dev is not loaded in Launchpad for tk8.5-dev in Hardy"

#fi

#if [[ ${DISTRIB_CODENAME} < "quantal" ]]
#then
    #sed -i '/^Build-Depends/s/libtiff5-dev/libtiff4-dev/' debian/control
    #dch -a "debian/control: Downgrade libtiff5 to libtiff4."
##    sed -i 's/--with-system-pcre/--without-system-pcre/g' debian/rules
##    dch -a "debian/rules: Change compile option to '--without-system-pcre' for releases older than Precise"
#fi


# Revert changes Dirk needed for unstable
#sed -i '/FIXME/s/#.*FIXME //' debian/rules
#dch -a "debian/rules: Revert changes in dealing with info files Dirk needed for unstable"

#cd debian
#rm r-base-core.postinst
#wget math.bd.psu.edu/faculty/rutter/R/r-base-core.postinst
#dch -a "debian/control: Fix permissions issue in r-base-core.postinst"
#cd ..

# Build package
#    dpkg-checkbuilddeps
    if [ $? -ne 0 ]; then
	exit 1
    fi
    debuild -S -sa
#    debuild -S -us -uc
#    dpkg-buildpackage -tc -uc -us
    if [ $? -ne 0 ]; then
	exit 1
    fi
    cd ..
	if [ $? -ne 0 ]; then
   		exit 1
	fi
