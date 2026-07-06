#' Diagnose test infrastructure
#'
#' Check if test infrastructure is present and refers to the current package.
#'
#' @param path [character string][checkinput::is_character()] containing a
#' [valid path][checkinput::is_path()] where to look for the file that
#' determines the test infrastructure.
#'
#' @details
#' The default `path` points to file `tinytest.R` in directory `tests` of the
#' current [working directory][getwd()], to check the test infrastructure of
#' [`tinytest`](https://CRAN.R-project.org/package=tinytest). Use
#' `path = fs::path_wd("tests", "testthat.R")` to check the test infrastructure
#' of [`testthat`](https://CRAN.R-project.org/package=testthat).
#'
#' A warning is issued if a file determining the used testing infrastructure
#' (e.g., `<pkg>\tests\tinytest.R` or `<pkg>\tests\testthat.R`) exists but:
#' - it does **not** refer to the tested package
#' - the package that governs the determined testing infrastructure (e.g.,
#'   `tinytest` or `testthat`) is missing from the dependencies of the tested
#'   package
#'
#' `diagnose_test_infra()` does **not** warn about problems detected with the
#' test infrastructure: that is deferred to [check_tests()].
#'
#' @returns
#' A [list] with three elements:
#' - `name`: character string containing the name of the test infrastructure
#'   that is looked for
#' - `status`: character string indicating the status of the test infrastructure:
#'   `"fine"` if it is present and refers to package `pkg`; `"wrong"` if it is
#'   present but does **not** refer to package `pkg`; `"missing"` if it is
#'   **not** present
#' - `dependency`: character string: `"fine"` if the package belonging to the
#'   testing infrastructure (i.e., `name`) is present among the dependencies of
#'   package `pkg`, otherwise `"missing"`
#'
#' @family
#' functions to check tests
#'
#' @examples
#' path_develcoder <- find.package("develcoder")
#' # test infrastructure is present
#' diagnose_test_infra(path = fs::path(path_develcoder, "tests", "tinytest.R"))
#'
#' # test infrastructure is not present
#' tempdir_example <- progutils::create_tempdir(prefix = "diagnose_test_infra")
#' withr::with_dir(new = tempdir_example, {
#'   # Set up a package without testing infrastructure
#'   desc <- desc::description$new("!new")
#'   desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
#'   diagnose_test_infra(path = fs::path(tempdir_example, "tests", "tinytest.R"))
#' })
#'
#' @export
diagnose_test_infra <- function(path = fs::path_wd("tests", "tinytest.R")) {
  stopifnot(checkinput::is_path(path))

  path_desc <- fs::path(dirname(dirname(path)), "DESCRIPTION")
  if(!fs::is_file(path_desc)) {
    stop("No DESCRIPTION file found at ", progutils::paste_quoted(path_desc),
         ", incorrect 'path'?:\n", path)
  }

  name <- sub(pattern = "\\.R$", replacement = "", x = basename(path),
              ignore.case = TRUE)
  pkg <- basename(dirname(dirname(path)))
  overview_infra <- list(name = name, status = NA_character_,
                         dependency = NA_character_)

  if(fs::is_file(path)) {
    if(any(grepl(pattern = paste0("\"", pkg, "\""),
                 x = readLines(con = path, warn = FALSE),
                 fixed = TRUE))) {
      overview_infra$status <- "fine"
    } else {
      overview_infra$status <- "wrong"
    }
  } else {
    overview_infra$status <- "missing"
  }


  if(!fs::is_file(path)) {
    overview_infra$status <- "missing"
  } else {
    if(!any(grepl(pattern = paste0("\"", pkg, "\""),
                  x = readLines(con = path, warn = FALSE),
                  fixed = TRUE))) {
      overview_infra$status <- "wrong"
    } else {
      overview_infra$status <- "fine"
    }
  }

  if(name %in% desc::desc_get_deps(file = path_desc)[, "package"]) {
    overview_infra$dependency <- "fine"
  } else {
    overview_infra$dependency <- "missing"
  }

  if(overview_infra$status == "wrong") {
    warning("The file determining the used testing infrastructure exists but",
            " does not refer\nto package ", progutils::paste_quoted(pkg), ":\n'",
            path, "'")
  }

  if(overview_infra$status != "missing" &&
     overview_infra$dependency == "missing") {
    warning("Add package '", name, "' as suggested dependency of package ",
            progutils::paste_quoted(pkg), ".")
  }

  overview_infra
}
