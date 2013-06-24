CRAN-PPA
========

These are the scripts that are used to upload R and R related packages to a Launchpad PPA.  This code uses the Debian source packages that all already available.  The scripts make minor modifications in order for the packages to work under Ubuntu and uploads the packages to a PPA.

The scripts assume that a chroot has been created for each release of Ubuntu that a package will be uploaded for.  From the main system, one of the "update" scripts is ran.  This in turn creates the packages to be uploaded in each chroot.  The "sync_build_ppa.sh" script syncs the build script to each release.

 
