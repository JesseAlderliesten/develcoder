#' Diagnose test files
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
#' A warning is issued if:
#' - `path` contains files that are ignored because their names do **not** start
#'   with pattern `pattern`, are not \R files, or are template files created by
#'   [`tinytest`](https://CRAN.R-project.org/package=tinytest)
#'
#' `diagnose_test_files()` does **not** warn about other problems detected with
#' the test files: that is deferred to [check_tests()].
#'
#' @returns
#' A [list] with six elements:
#' - `pattern`: the value of argument `pattern`
#' - `ignore_case`: the value of argument `ignore_case`
#' - `status_testdir`: character string: `"fine"` if the test directory
#'   indicated by `path` is present, otherwise `"missing"`
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

  path_desc <- fs::path(dirname(dirname(path)), "DESCRIPTION")
  if(!fs::is_file(path_desc)) {
    stop("No DESCRIPTION file found at ", progutils::paste_quoted(path_desc),
         ", incorrect 'path'?:\n", path)
  }

  pkg <- basename(dirname(path_desc))

  overview_test_files <- list(
    pattern = pattern, ignore_case = ignore_case,
    status_testdir = "missing", status_test_files = "missing",
    test_files = character(0), ignored_files = character(0))

  testdir_present <- fs::dir_exists(path)
  if(testdir_present) {
    overview_test_files$status_testdir <- "present"
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
        warning("Ignoring files that are not R files, are template files created by ",
                progutils::paste_quoted(basename(path)), " or\nhave names that",
                " do not start with 'pattern' (", progutils::paste_quoted(pattern),
                "):\n", progutils::paste_quoted(overview_test_files$ignored_files))
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
