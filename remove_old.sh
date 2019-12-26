#!/bin/bash

cd /home/mrutter/CRAN

howmany() { echo $#; }
FILETYPE=".tar.gz .diff.gz .dsc"
. ~/CRAN/packages.txt

releases=${CRANReleases}
ArchiveDir=/home/cran/ubuntu

for r in ${releases}; do
	cd ${ArchiveDir}/${r}
	for ext in $FILETYPE
	do
		PKG="$(ls *${ext} | cut -d '_' -f 1 | sort -u)"
		echo "${PKG}"
		
		for i in $PKG
		do
			DELFILES="$(ls -1tr ${i}*${ext} | head -n -2)"
			#echo "${DELFILES}"
			howmany $DELFILES
			for j in $DELFILES
			do
				echo "Deleting ${j}"
				rm "${j}"
			done
		done
	done 
done

FILETYPE=".deb"

for r in ${releases}; do
	cd ${ArchiveDir}/${r}
	for ext in $FILETYPE
	do
		PKG="$(ls *${ext} | cut -d '_' -f 1 | sort -u)"
		echo "${PKG}"
		
		for i in $PKG
		do
			DELFILES="$(ls -1tr ${i}*${ext} | head -n -10)"
			#echo "${DELFILES}"
			howmany $DELFILES
			for j in $DELFILES
			do
				echo "Deleting ${j}"
#				rm "${j}"
			done
		done
	done 
done

exit 0

