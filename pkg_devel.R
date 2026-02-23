#### Install required packages ####
required_pkgs <- c("devtools", "tinytest", "usethis")
bool_install <- !vapply(X = required_pkgs, FUN = requireNamespace,
                        FUN.VALUE = logical(1), quietly = TRUE)
pkgs_install <- required_pkgs[bool_install]
if(length(pkgs_install) > 0L) {
  utils::install.packages(pkgs = pkgs_install, lib = NULL, dependencies = NA,
                          quiet = FALSE)
}


#### Add functions ####
##### Setting up #####
# Write function and documentation
usethis::use_r("is_number")
devtools::document() # also runs devtools::load_all()
?is_number() # view help-page of the function
# Do:
# - Manually update the NEWS-file.


##### Components of documentation #####
#' Title
#'
#' Description
#'
#' @inheritParams is_logical # From another function in the current package
#' @inheritParams utils::installed.packages # from a function in another package
#' @param x Vector of names to test.
#' @param allow_underscores `TRUE` or `FALSE`: allow underscores?
#'
#' @details
#'
#' @returns
#' `TRUE` or `FALSE`, returned [invisibly][invisible].
#'
#' @section Notes:
#' Some notes.
#'
#' @section Programming notes:
#' Some programming notes. Create a GitHub issue instead of To do / Wishlist
#' sections.
#'
#' @seealso
#' Section `Details` of [make.names()] and the [\R FAQ about valid names](
#' https://CRAN.R-project.org/doc/manuals/R-FAQ.html#What-are-valid-names_003f)
#' on the syntactical validity of names.
#'
#' @family
#' collections of checks on type and length
#'
#' @examples
#' all_names(x = c("a", "b1a")) # TRUE
#'
#' @export
func_name <- function(x, allow_underscores = TRUE) {
  stopifnot(is_logical(allow_underscores))
}

##### To inherit sections #####
#' @inherit is_number details
#' @inheritSection is_logical Programming notes
#' @inheritSection is_logical @note


#### Add tests ####
library(tinytest)
tinytest::test_all() # Run all tests of a package
tinytest::run_test_file("./inst/tinytest/test_funcname.R") # Run specific file
# Note: expect_silent(expect_equal()) does NOT test that no messages are emitted!
expect_silent(expect_true(func_name(x = x, arg = arg)))
expect_warning(
  expect_equal(func_name(x = "a", arg = arg), 3),
  pattern = "...", strict = TRUE, fixed = TRUE)
expect_error(func_name(x = "a", arg = arg),
             pattern = "is_number(x) is not TRUE", fixed = TRUE)

##### Using temporary files #####
# - Could also use local(...)? See withr::with_tempfile()
#   \dontshow{
#     my_tempdir <- tempdir()
#     example_dir <- file.path(my_tempdir, example_dir)
#   }
#   See also https://stat.ethz.ch/pipermail/r-devel/2018-March/075783.html
# - On the problem of changing relative paths depending on how a check is run,
#   see `testthat::test_path()`.


#### Add vignettes ####
##### Setting up #####
usethis::use_vignette("my_vignette", title = "Some title")
usethis::use_package(package = "knitr", type = "Suggests")
usethis::use_package(package = "rmarkdown", type = "Suggests")
devtools::document()
browseVignettes(package = basename(getwd()))
devtools::build_vignettes()

# If no vignettes are visible, devtools::install() was probably run with the
# default 'build_vignettes = FALSE': change it to use 'build_vignettes = TRUE:
devtools::install(quick = FALSE, upgrade = "never", build_vignettes = TRUE)

# See also: tools::pkgVignettes(package = "checkrpkgs")

##### Styling #####
# Put the next lines in the header of vignettes to get a table of contents:
# output:
#   rmarkdown::html_vignette:
#     toc: true
#     toc_depth: 3

# See also my Chrome Bookmarks R > Workflow > RMarkdown.

##### Linking #####
# For internal links to other sections in the same document ('Section', 'above',
# 'below'): [<Section title>] or [<link text>][<Section title>]

# To link from vignettes to help-pages, use [someFun](../help/someFun) (from
# https://stackoverflow.com/questions/34946219). Text between angled brackets
# (e.g., <pkgname>) disappears when used in link text, so instead of
# [library(<pkgname>)](../help/library), use [library](../help/library)`(<pkgname>)`.
# For a more advanced way of linking from vignettes to help-pages see
# https://github.com/dmurdoch/rgl/commit/bbc84447c2a6efed42907fbac176e9569b868d8f

# To link from help-pages to vignettes, use:
# The [vignette about <some description>](../doc/<filename>.html).
# If no vignettes are visible, run devtools::build_vignettes(), which possibly
# needs to be followed by install(..., build_vignettes = TRUE).


#### Preparing for updates
# Restyle and publish the NEWS-file at each new package release.
devtools::document()

# Check for which functions no test file has been written.
files_R <- list.files(file.path(".", "R"))
files_man <- list.files(path = file.path(".", "man"), pattern = "\\.Rd$")
expected_man <- sub(pattern = "\\.Rd$", replacement = ".R", x = files_man)
expected_files <- sort(unique(paste0("test_", c(files_R, expected_man))))
expected_files[!(expected_files %in% list.files("./inst/tinytest"))]

tinytest::test_all()

# Using 'manual = FALSE' because building the manual leads to latex errors.
devtools::check(manual = FALSE, force_suggests = TRUE, run_dont_test = TRUE)


#### Updating dependencies ####
# 'use_package()' to declare minimum version and 'use_dev_package()' to set remote.
usethis::use_package(package = "checkinput", type = "Imports", min_version = TRUE)
usethis::use_dev_package(package = "checkinput", type = "Imports",
                         remote = "github::JesseAlderliesten/checkinput")

##### Importing packages or functions #####
# Packages from which functions are imported should ALSO be listed in the
# Imports field of the DESCRIPTION file. For example, to import 'osVersion'
# from package 'utils', one should add a line in R/<pkgname>-package.R:
# #' @importFrom utils osVersion
# and add a line in the DESCRIPTION file:
# Imports: utils
# Both are done by usethis::use_import_from(), might have to use
# devtools::document() for this to take effect.
pkg_to_import <- "checkinput"
# NB. Modifies <pkgname>-package.R in the R/ directory that was created by usethis::use_package_doc().
usethis::use_import_from(package = pkg_to_import,
                         fun = list.files(
                           file.path(dirname(getwd()), pkg_to_import, "R")))
usethis::use_import_from(package = "BiocManager", fun = "valid")


#### Increment package version ####
# To increment the package version, adjust the package version in the
# DESCRIPTION file, or run R as administrator and then use usethis::use_version().
# In the latter case, do not automatically commit the change, but do so manually
# to adjust the commit message to, e.g., Bump version. Breaking change: <func>
# no longer ... .


#### Test package ####
.libPaths() # Check if output of .libPaths() is correct.
devtools::install(quick = FALSE, upgrade = "never", build_vignettes = TRUE)

# Load the package and view the help files as usual outside devtools:
library(checkinput)
?all_names
browseVignettes(package = basename(getwd()))
# If no vignettes are visible, devtools::install() was probably run with the
# default 'build_vignettes = FALSE': change it to use 'build_vignettes = TRUE'.


#### Setting up new GitHub branch ####
# Then merge the devel-branch with master.
# After a successful merge, you can delete the devel-branch.

# Then set up a new GitHub branch:
# - At the GitHub page of the package:
#   'Branch' icon > green `New branch` button > `<pkgname>_devel > green `Create new branch` button.
# - Go back to the GitHub page of the package, and at the green `Code` button > copy URL to clipboard.
# - In RStudio: `File` > `New project` > `Version control` > `Git` and paste the
#   copied URL in the `Repository URL` > `Create Project`.
# - Then (still in RStudio) in the `Git` menu change from `master` to the `<pkgname>_devel-branch.


#### Troubleshooting ####
# To prevent regex-classes in example code from being interpreted as links,
# which leads to the error '@section Could not resolve link to topic ":blank:"
# in the dependencies or base packages' when running devtools::document(), use
# backticks to format a line as code, or wrap consecutive lines in \code{...}.
