#' Check tests
#'
#' Check if testing infrastructure is present and refers to the current package,
#' and if function files have a corresponding test file and vice versa.
#'
#' @inheritParams diagnose_test_files
#' @param path [character string][checkinput::is_character()] containing a
#' valid [path][checkinput::is_path()] to the package of which to check testing
#' infrastructure and test files. The default is the [working directory][getwd()].
#'
#' @details
#' This function looks for \R files starting with pattern `pattern` in folders
#' `inst/tinytest` and `tests/testthat` in the directory indicated by `path`,
#' which is where [`tinytest`](https://CRAN.R-project.org/package=tinytest)
#' and [`testthat`](https://CRAN.R-project.org/package=testthat) place their
#' test files, respectively.
#'
#' It is checked that testing infrastructure is present and refers to the
#' current package, and that all test files have corresponding function files
#' and vice versa. Test files are ignored if the corresponding test
#' infrastructure is missing or wrong, with a warning. Function files of
#' re-exported functions are ignored when looking for corresponding test files
#' because these functions should be tested in the package from which they are
#' re-exported.
#'
#' Warnings are issued if:
#'
#' - none of the test directories [exist][fs::dir_exists()]
#' - none of the test directories contain test files
#' - test directories contain files that are ignored because their names do
#'   **not** start with pattern `pattern`, are not \R files, or are template
#'   files created by [`tinytest`](https://CRAN.R-project.org/package=tinytest)
#'   or [`testthat`](https://testthat.r-lib.org/)
#' - test directories used by `tinytest` or `testthat` contain test files while
#'   their test architecture is not set up
#' - test directories contain test files without corresponding function files in
#'   folder `R`
#' - folder `R` contains function files without corresponding test files
#' - folder `R` contains files that are not R files
#' - folder `R` does not contain any function files
#' - files `<pkg>\tests\tinytest.R` or `<pkg>\tests\testthat.R` determining
#'   which test infrastructure is used are present but do **not** refer to the
#'   current package, or the packages `tinytest` and `testthat` are missing from
#'   the dependencies of the tested package
#' - file `<pkg>\tests\tinytest.R` nor `<pkg>\tests\testthat.R` is present
#' - file `reexports.Rd` is present in folder `man` but no re-exported functions
#'   are present in folder `R`
#'
#' @returns
#' If all function files in folder `R` have a corresponding used test file and
#' vice versa (which also is the case if no test files and no function files are
#' present): `character(0)`. Otherwise, a character vector with the names of
#' test files for which no function file is present and function files for which
#' no used test file is present.
#'
#' @family
#' functions to check tests
#'
#' @examples
#' path_develcoder <- find.package("develcoder")
#' # test files are present
#' check_tests(path = path_develcoder) # character(0)
#'
#' # warnings: test infrastructure, directories, and function files not present
#' tempdir_example <- progutils::create_tempdir(prefix = "check_tests")
#' withr::with_dir(new = tempdir_example, {
#'   # Set up a package without testing infrastructure
#'   desc <- desc::description$new("!new")
#'   desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
#'   check_tests(path = tempdir_example)
#' })
#' # Remove temporary directory
#' unlink(tempdir_example, recursive = TRUE)
#'
#' @export
check_tests <- function(path = getwd(), pattern = "^test_|^test-",
                        ignore_case = TRUE) {
  stopifnot(checkinput::is_path(path), checkinput::is_character(pattern),
            checkinput::is_logical(ignore_case))

  path_desc <- fs::path(path, "DESCRIPTION")
  if(!fs::is_file(path_desc)) {
    stop("No DESCRIPTION file found at ", progutils::paste_quoted(path_desc),
         ", incorrect 'path'?:\n", path)
  }

  pkg <- basename(path)
  path_infra_tinytest <- fs::path(path, "tests", "tinytest.R")
  infra_tinytest <- diagnose_test_infra(path = path_infra_tinytest)
  path_infra_testthat <- fs::path(path, "tests", "testthat.R")
  infra_testthat <- diagnose_test_infra(path = path_infra_testthat)
  if(infra_tinytest$status == "missing" && infra_testthat$status == "missing") {
    warning("No file determining the used testing infrastructure exists:\n",
            progutils::paste_quoted(path_infra_tinytest), ",\n",
            progutils::paste_quoted(path_infra_testthat))
  }

  warn_ignore_p1 <- "Test files will be ignored because test infrastructure for"
  warn_ignore_p2 <- "is missing\nor does not refer to the current package (run"
  warn_ignore_p3 <- "to\ncreate the test infrastructure):\n"
  path_tinytest <- fs::path(path, "inst", "tinytest")
  path_testthat <- fs::path(path, "tests", "testthat")
  files_tinytest <- diagnose_test_files(
    path = path_tinytest, pattern = pattern, ignore_case = ignore_case)
  if(length(files_tinytest$test_files) > 0L && infra_tinytest$status != "fine") {
    warning(warn_ignore_p1, " tinytest ", warn_ignore_p2,
            " 'tinytest::setup_tinytest()' ", warn_ignore_p3,
            progutils::paste_quoted(files_tinytest$test_files))
    files_tinytest$ignored_files <- c(files_tinytest$ignored_files,
                                      files_tinytest$test_files)
    files_tinytest$test_files <- character(0)
  }

  files_testthat <- diagnose_test_files(
    path = path_testthat, pattern = pattern, ignore_case = ignore_case)
  if(length(files_testthat$test_files) > 0L && infra_testthat$status != "fine") {
    warning(warn_ignore_p1, " testthat ", warn_ignore_p2,
            " 'usethis::use_testthat()' ", warn_ignore_p3,
            progutils::paste_quoted(files_testthat$test_files))
    files_testthat$ignored_files <- c(files_testthat$ignored_files,
                                      files_testthat$test_files)
    files_testthat$test_files <- character(0)
  }

  test_files_present <- c(files_tinytest$test_files, files_testthat$test_files)
  bool_dir_missing <- c(files_tinytest$status_testdir,
                        files_testthat$status_testdir) == "missing"
  all_paths <- c(path_tinytest, path_testthat)

  if(all(bool_dir_missing)) {
    warning("None of the test directories exist:\n",
            progutils::paste_quoted(all_paths))
  } else {
    if(length(test_files_present) == 0L) {
      warning("None of the test directories contain used test files:\n",
              progutils::paste_quoted(all_paths))
    }
  }

  path_R <- fs::path(path, "R")
  R_files <- list.files(path_R)
  bool_not_R <- !endsWith(x = R_files, suffix = ".R")
  if(any(bool_not_R)) {
    warning("Ignoring non-R files in folder '", path_R, "':\n",
            progutils::paste_quoted(R_files[bool_not_R]))
    R_files <- R_files[!bool_not_R]
  }

  bool_proj_pkg_R_file <- grepl(pattern = ".package.R$", x = R_files)
  if(any(bool_proj_pkg_R_file)) {
    R_files <- R_files[!bool_proj_pkg_R_file]
  }

  if(any(grepl(pattern = "^reexports.Rd$",
               x = list.files(path = file.path(path, "man")),
               ignore.case = TRUE))) {
    exported_funcs <- getNamespaceExports(pkg)

    if(length(exported_funcs) == 0L ||
       # Based on https://stackoverflow.com/a/74487073/32365738
       length(progutils::not_in(exported_funcs,
                                ls(envir = asNamespace(pkg)))) == 0L) {
      warning("File 'reexports.Rd' is present in folder 'man' but no",
              " re-exported functions were found in folder 'R'!")
    } else {
      # Re-exported functions are ignored when looking for test files
      # corresponding to function files because these functions should be tested
      # in the package from which they are re-exported.
      R_files <- progutils::not_in(R_files, paste0(exported_funcs, ".R"))
    }
  }

  if(length(R_files) > 0L) {
    expected_test_files <- R_files
  } else {
    warning("No function files found.")
    expected_test_files <- character(0)
  }

  tests_missing <- progutils::not_in(
    expected_test_files,
    gsub(pattern = pattern, replacement = "", x = test_files_present,
         ignore.case = ignore_case))
  tests_extraneous <- progutils::not_in(
    gsub(pattern = pattern, replacement = "", x = test_files_present,
         ignore.case = ignore_case),
    expected_test_files)
  if(length(tests_missing) > 0L) {
    warning("No test file found corresponding to function file ",
            progutils::paste_quoted(
              sort(gsub(pattern = pattern, replacement = "", x = tests_missing))
            )
    )
  }

  if(length(tests_extraneous) > 0L) {
    warning("No function file found corresponding to test file ",
            progutils::paste_quoted(sort(tests_extraneous)))
  }

  sort(c(tests_missing, tests_extraneous))
}
