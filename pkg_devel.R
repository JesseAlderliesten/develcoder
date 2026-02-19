#### Install packages ####
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

# Save documentation as ...
devtools::document() # also runs devtools::load_all()
?is_number() # view help-page of the function

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


#### Vignettes ####
##### Setting up #####
usethis::use_vignette("my_vignette", title = "Some title")
devtools::document()
browseVignettes(package = basename(getwd()))
devtools::build_vignettes()

# If no vignettes are visible, devtools::install() was probably run with the
# default 'build_vignettes = FALSE': change it to use 'build_vignettes = TRUE:
devtools::install(quick = FALSE, upgrade = "never", build_vignettes = TRUE)



##### Styling #####
# Put the next lines in the header of vignettes to get a table of contents:
# output:
#   rmarkdown::html_vignette:
#     toc: true
#     toc_depth: 3

##### Linking #####
# For internal links to other sections in the same document ('Section', 'above',
# 'below'): [<Section title>] or [<link text>][<Section title>]

# To link from help-pages to vignettes, use:
# The [vignette about <some description>](../doc/<filename>.html).
# If no vignettes are visible, run devtools::build_vignettes(), which possibly
# needs to be followed by install(..., build_vignettes = TRUE).

# To link from vignettes to help-pages, see
# https://github.com/dmurdoch/rgl/commit/bbc84447c2a6efed42907fbac176e9569b868d8f
# and https://stackoverflow.com/questions/34946219/linking-r-package-vignettes.


#### Troubleshooting ####
# To prevent regex-classes in example code from being interpreted as links,
# which leads to the error '@section Could not resolve link to topic ":blank:"
# in the dependencies or base packages' when running devtools::document(), use
# backticks to format a line as code, or wrap consecutive lines in \code{...}.
