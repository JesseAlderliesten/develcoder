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
# For an overview of licenses, see https://choosealicense.com/ and
# https://www.gnu.org/licenses/gpl-faq.html.
usethis::use_mit_license() # A permissive license.

# See also https://citation-file-format.github.io/cff-initializer-javascript/
cffr::cff_write()

# Creates R/<pkgname>-package.R to list imported functions. That file can also
# be used as help-page such that help(<pkgname>) produces a description of the
# package with an overview of its functions.
usethis::use_package_doc()
# Creates README.Rmd and README.md

usethis::use_readme_rmd()
# Do:
# - Manually update README.Rmd (see the template file `README_template.Rmd` in
#   the folder `templates`), then use devtools::build_readme() to update
#   README.md. To override the requirement to have README.Rmd and README.md
#   staged at the same time, delete the (hidden) file .git/hooks/pre-commit from
#   the project folder, see https://github.com/r-lib/usethis/issues/312.
devtools::build_readme()
# - Add a badge with the version number by including the following code (replace
#   <pkgname>; the badge does not yet work if the GitHub repository is private):
#   ![](https://img.shields.io/github/r-package/v/JesseAlderliesten/<pkgname>?color=blue)
# - Run devtools::build_readme() to update README.md.

# Create a NEWS-file.
usethis::use_news_md()
# Update the NEWS-file (see the template file `README_template.Rmd` in the
# folder `templates`).


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
usethis::use_package(package = "tinytest", type = "Suggests")
devtools::document()


#### Set up a GitHub repository ####
# See vignette(topic = "git_github", package = "checkrpkgs")
usethis::use_git(message = "Initial commit")
# If you get the error message you are not the current owner of the GitHub
# repository, restart R as administrator and try again.
usethis::use_github(private = TRUE)


#### Use GitHub Actions ####
# GitHub Actions (GHA) is a continuous integration service to automatically run
# code upon certain triggers. Setting GHA to run 'check-no-suggests' from
# https://github.com/r-lib/actions/blob/v2-branch/examples/check-standard.yaml
# ensures the code passes R-CMD check when dependencies in `Suggests` are not
# installed.
usethis::use_github_action("check-no-suggests")

# Then adjust the YAML file (i.e., <pkg>\.github\workflows\check-no-suggests.yaml)
# to include some other useful triggers for GHAs (see the template file
# `check-no-suggests.yaml` in the folder `templates`):
# - you made changes to code in the current repository: add 'push:' to 'on:' to
#   run GHA on pushes.
# - someone else proposed changes to code in the current repository: add
#   'pull_request:' to 'on:' to run GHA on pull requests.
# - you changed package A and want to check if package B, which depends on
#   package A, is still working fine): add 'workflow_dispatch:' to 'on:' to be
#   able to manually trigger GHA. See the section 'Use GitHub Actions' in
#   pkg_devel.R on how to use it.
# - someone else made changes to packages your package depends on: add e.g.
#   'schedule: - cron: "23 4 * * 6"' to 'on:' to run every Saturday on 04:23 UTC.
#   The cron specification consists of five elements that indicate the minute
#   (0 - 59), hour (0 - 23), day of the month (1 - 31), month (1 - 12), and day
#   of the week (0 - 6).

# If the package declares a dependency on a specific R version, it is useful to
# specify the minimum declared R version to run in addition to the ones that are
# by default used in the template: add '- {os: ubuntu-latest,   r: '4.0.0'}' to
# the 'matrix: config:' part to run R 4.0.0.

##### Further documentation #####
# The file progutils\.github\workflows\R-CMD-check.yaml is a good example.
# https://r-pkgs.org/software-development-practices.html#sec-sw-dev-practices-gha
# GitHub documentation at
# https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax
