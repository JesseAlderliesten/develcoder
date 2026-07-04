#' Get test files
#'
#' Get test files, with an overview of various diagnostics
#'
#' @param path [character string][checkinput::is_character()] containing a
#' [valid path][checkinput::is_path()] to the directory where to look for tests.
#' @param pattern [character string][checkinput::is_character()] containing a
#' [regular expression][regex] used to select test files.
#' @param ignore_case `TRUE` or `FALSE`: ignore case when matching filenames to
#' `pattern`?
#'
#' @details
#' The default `path` points to directory `inst/tinytest` of the current
#' [working directory][getwd()], where
#' [`tinytest`](https://CRAN.R-project.org/package=tinytest) stores tests when a
#' package is in development.
#'
#' [Signalling][progutils::signal_text()] problems detected with the test files
#' is **not** done by `diagnose_test_files()` but is deferred to [check_test_files()].
#'
#' @returns
#' A [list] with eight elements:
#' - `pkg`: character string containing the name of the package of which test
#'   files are checked
#' - `path`: the value of argument `path`
#' - `pattern`: the value of argument `pattern`
#' - `ignore_case`: the value of argument `ignore_case`
#' - `testdir`: character string: `"fine"` if the test directory indicated by
#'   `path` is present, otherwise `"missing"`
#' - `status_test_files`: character string indicating the status of the test
#'   files: `"fine"` if test files are present; `"wrong"` if files are ignored;
#'   `"missing"` if no test files are present
#' - `test_files`: character vector with the names of test files. `character(0)`
#'   if no test files are present.
#' - `ignored_files`: character vector with the names of files in `path` that
#'   are **not** test files. `character(0)` if no files are ignored.
#'
#' @family
#' functions to check tests
#'
#' @examples
#' path_develcoder <- find.package("develcoder")
#' # test files are present
#' diagnose_test_files(path = fs::path(path_develcoder, "inst", "tinytest"))
#'
#' # test directory is missing
#' diagnose_test_files(path = fs::path(path_develcoder, "inst", "othertest"))
#'
#' # empty test directory
#' tempdir_example <- progutils::create_tempdir(prefix = "diagnose_test_files")
#' withr::with_dir(new = tempdir_example, {
#'   # Set up a package with testing infrastructure from tinytest
#'   desc <- desc::description$new("!new")
#'   desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
#'   desc::desc_set(Package = "somepkg")
#'
#'   fs::dir_create(fs::path(tempdir_example, "inst", "tinytest"))
#'   diagnose_test_files(path = fs::path(tempdir_example, "inst", "tinytest"))
#' })
#'
#' @export
diagnose_test_files <- function(path = fs::path_wd("inst", "tinytest"),
                                pattern = "^test_|^test-", ignore_case = TRUE) {
  stopifnot(checkinput::is_path(path), checkinput::is_character(pattern),
            checkinput::is_logical(ignore_case))

  pkg <- basename(dirname(dirname(path)))
  if(pkg == ".") {
    stop("No package name found, incorrect 'path'?: ", path)
  }

  overview_test_files <- list(
    pkg = pkg, path = path, pattern = pattern, ignore_case = ignore_case,
    testdir = "missing", status_test_files = "missing",
    test_files = character(0), ignored_files = character(0))

  testdir_present <- fs::dir_exists(path)
  if(testdir_present) {
    overview_test_files$testdir <- "present"
    testfiles <- basename(fs::dir_ls(path = path, type = "file", fail = FALSE))
    if(length(testfiles) > 0L) {
      names_error_init <- !grepl(pattern = pattern, x = testfiles,
                                 ignore.case = ignore_case)
      names_error_end <- !grepl(pattern = ".R$", x = testfiles,
                                ignore.case = ignore_case)
      # Template used by 'tinytest'
      names_error_template <- testfiles %in% paste0("test_", pkg, ".R")
      names_error <- names_error_init | names_error_end | names_error_template
      if(any(names_error)) {
        overview_test_files$status_test_files <- "wrong"
        overview_test_files$ignored_files <- testfiles[names_error]
        testfiles <- testfiles[!names_error]
        if(length(testfiles) == 0L) {
          overview_test_files$status_test_files <- "missing"
        }
      } else {
        overview_test_files$status_test_files <- "fine"
      }
      overview_test_files$test_files <- testfiles
    }
  }

  overview_test_files
}
