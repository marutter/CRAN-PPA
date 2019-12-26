library(cran2deb)
setwd("~/R/PPA/rebuild_universe")

library(stringr)
library(rPython)

aval.src.pkgs <- read.csv("list_of_universe_packages.csv",stringsAsFactors=FALSE)
local.order <- r_dependency_closure(aval.src.pkgs$package)
upload.order <- unlist(local.order[local.order %in% aval.src.pkgs$package])

n.pkg <- length(upload.order)

for (pkg in 1:5) {
  #  closeAllConnections()
  pkg.name <- upload.order[pkg]
  # python.assign("pkg",tolower(pkg.name))
  # python.assign("SOURCE_SERIES","trusty")
  # python.load("package_info.py", get.exception = TRUE)
  # number <- python.get("package.source_package_version")
  notice(pkg.name,'to be rebuilt with backport')
  url <- aval.src.pkgs$URL[aval.src.pkgs$package==upload.order[pkg]]
  command <- paste("./backport_xenial_list.sh ",url)
  system(command)
  Sys.sleep(120)
}

write.csv(aval.src.pkgs[match(upload.order,aval.src.pkgs$package),3],"bionic_order.csv",row.names = FALSE)
