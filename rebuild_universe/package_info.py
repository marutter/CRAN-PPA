#!/usr/bin/python
"""
Find the version number of a package and the date it was published
"""
 
import optparse
from collections import defaultdict
#import launchpadlib
from launchpadlib.launchpad import Launchpad
import sys 
 
 
PPA_OWNER = 'marutter'
PPA_NAME = 'c2d4u'

#pkg = sys.argv[1]
#SOURCE_SERIES = sys.argv[2]  



print pkg


lp = Launchpad.login_with('c2d4u-inspect-packages', 'production',version='devel')

owner = lp.people[PPA_OWNER]
ppa = owner.getPPAByName(name=PPA_NAME)
print ppa

source_series = ppa.distribution.getSeries(name_or_version=SOURCE_SERIES)

package = ppa.getPublishedSources(exact_match=True, source_name=pkg, distro_series=source_series)[0]
print package.source_package_name
print package.source_package_version
pub_info = str(package.date_published)
#pocket = package.pocket



