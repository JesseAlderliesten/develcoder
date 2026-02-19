#### Install packages to use this script ####
required_pkgs <- c("cffr", "devtools", "pkgdepends", "tinytest", "usethis")
bool_install <- !vapply(X = required_pkgs, FUN = requireNamespace,
                        FUN.VALUE = logical(1), quietly = TRUE)
pkgs_install <- required_pkgs[bool_install]
if(length(pkgs_install) > 0L) {
  utils::install.packages(pkgs = pkgs_install, lib = NULL, dependencies = NA,
                          quiet = FALSE)
}


#### Choose a name ####
pkgname <- "develcoder"

# Is the intended name valid?
pkgdepends::is_valid_package_name(nm = pkgname)
# Is the intended name available?
unlist(pkgdepends::pkg_name_check(name = pkgname)$basics)
browseURL(url = paste0("https://github.com/search?q=", pkgname,
                       "&type=repositories"))
browseURL(url = paste0("https://github.com/search?q=", pkgname,
                       "+language%3AR+&type=repositories"))


#### Create the package ####
path_to_package <- file.path("D:", "Userdata", "Jesse Nieuw", "Documents", "R",
                             pkgname)
# This copies information from your .Rprofile file (I have a .Rprofile file at
# "D:\Userdata\Jesse Nieuw\Documents\.Rprofile", see ?Startup for details), see
# usethis::use_description and https://usethis.r-lib.org/articles/usethis-setup.html.
usethis::create_package(path = path_to_package)

# Do:
# - Update the 'Title' field of the DESCRIPTION file.
# - Update the 'Description' field of the DESCRIPTION file.


#### Add package-wide documentation ####
# Run R as administrator

# Keep 'license.Rmd': it is required by R CMD check.
usethis::use_mit_license()
# See also https://citation-file-format.github.io/cff-initializer-javascript/
cffr::cff_write()
# Creates R/<pkgname>-package.R to list imported functions. That file can also
# be used as help-page such that help(<pkgname>) produces a description of the
# package with an overview of its functions.
usethis::use_package_doc()
# Creates README.Rmd and README.md

usethis::use_readme_rmd()

# Do:
# - Manually update README.Rmd
# - Add a badge with the version number by including the following line:
#   ![](https://img.shields.io/github/r-package/v/JesseAlderliesten/<pkgname>)
# - Run devtools::build_readme() to update README.md.

# Create a NEWS-file.
usethis::use_news_md()


#### Importing packages or functions ####
# 'use_package()' to declare minimum version and 'use_dev_package()' to set remote.
usethis::use_package(package = "checkinput", type = "Imports", min_version = TRUE)
usethis::use_dev_package(package = "checkinput", type = "Imports",
                         remote = "github::JesseAlderliesten/checkinput")
usethis::use_package(package = "progutils", type = "Imports", min_version = TRUE)
usethis::use_dev_package(package = "progutils", type = "Imports",
                         remote = "github::JesseAlderliesten/progutils")
devtools::document()


#### Set up testing ####
tinytest::setup_tinytest(pkgdir = ".")


#### Set up a GitHub repository ####
# See vignette(topic = "git_github", package = "checkrpkgs")
usethis::use_git(message = "Initial commit")
usethis::use_github(private = TRUE)
