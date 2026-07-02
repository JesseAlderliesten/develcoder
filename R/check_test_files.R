#' Check for the presence of test files
#'
#' Check if all function files have a corresponding test file and vice versa.
#'
#' @inheritParams get_test_files pattern ignore_case
#' @param path_pkg [character string][checkinput::is_character()] containing a
#' valid [path][checkinput::is_path()] to the package to be checked. The default
#' is the [working directory][getwd()].
#'
#' @details
#' This function looks for \R files starting with pattern `pattern` in folders
#' `inst/tinytest`, `tinytest`, and `tests/testthat` in the directory indicated
#' by `path_pkg`, where [`tinytest`](https://CRAN.R-project.org/package=tinytest)
#' and [`testthat`](https://CRAN.R-project.org/package=testthat) place their
#' test files, respectively.
#'
#' It is checked that all test files have corresponding function files and vice
#' versa. Function files of re-exported functions are ignored when looking for
#' corresponding test files because these functions should be tested in the
#' package from which they are re-exported.
#'
#' Warnings are issued if:
#'
#' - none of the test directories exist
#' - none of the test directories contain any test files
#' - the test directories contain files that are ignored because their names do
#'   not start with pattern `pattern`, are not \R files, or are template files
#'   created by [`tinytest`]( https://CRAN.R-project.org/package=tinytest)
#' - the test directories contain test files without corresponding function
#'   files in folder `R`
#' - folder `R` contains function files without corresponding test files
#' - file `<pkg>\tests\tinytest.R` is present but its code does not contain the
#'   name of the current package
#' - a `reexports.Rd` file is present in folder `man` but no re-exported
#'   functions are found in folder `R`
#'
#' @returns
#' If all \R files have a corresponding test file: `character(0)`. Otherwise, a
#' character vector with the names of \R files for which no test file was found.
#'
#' @seealso
#' [get_test_files()] that is used by this function
#'
#' @examples
#'
#' @export
check_test_files <- function(path_pkg = getwd(), pattern = "^test_|^test-",
                             ignore_case = TRUE) {
  stopifnot(checkinput::is_path(path_pkg))
  pkg_name <- basename(path_pkg)
  warn_text <- character(0)

  warn_text <- c(
    warn_text,
    check_test_infra(path_infra = fs::path(path_pkg, "tests", "tinytest.R")),
    check_test_infra(path_infra = fs::path(path_pkg, "tests", "testthat.R"))
  )

  # The 'inst/tinytest' directory is relevant during package development, the
  # others are relevant when the package is installed.
  path_tinytest_inst <- fs::path(path_pkg, "inst", "tinytest")
  path_tinytest <- fs::path(path_pkg, "tinytest")
  path_testthat <- fs::path(path_pkg, "tests", "testthat")

  tinytest_test_files_inst <- get_test_files(
    testdir = path_tinytest_inst, pattern = pattern, ignore_case = ignore_case,
    signal = "quiet")
  tinytest_test_files <- get_test_files(
    testdir = path_tinytest, pattern = pattern, ignore_case = ignore_case,
    signal = "quiet")
  testthat_test_files <- get_test_files(
    testdir = path_testthat, pattern = pattern, ignore_case = ignore_case,
    signal = "quiet")

  all_paths <- c(path_tinytest_inst, path_tinytest, path_testthat)
  test_files_present <- c(tinytest_test_files_inst, tinytest_test_files,
                          testthat_test_files)
  all_attributes <- c(attr(tinytest_test_files_inst, "info"),
                      attr(tinytest_test_files, "info"),
                      attr(testthat_test_files, "info"))
  bool_dir_not_exist <- grepl(pattern = "does not exist",
                              x = all_attributes, fixed = TRUE)
  bool_dir_no_test_files <- grepl(pattern = "does not contain any testfiles",
                                  x = all_attributes, fixed = TRUE)

  if(all(bool_dir_not_exist)) {
    warn_text <- c(warn_text,
                   paste0("None of the test directories exist:\n",
                          progutils::paste_quoted(all_paths)))
  }

  if(all(bool_dir_not_exist | bool_dir_no_test_files)) {
    warn_text <- c(warn_text,
                   paste0("None of the test directories contains test files:\n",
                          progutils::paste_quoted(all_paths)))
  }

  R_files <- list.files(fs::path(path_pkg, "R"))
  bool_proj_pkg_R_file <- grepl(pattern = ".package.R$", x = R_files,
                                ignore.case = TRUE)

  if(any(bool_proj_pkg_R_file)) {
    R_files <- R_files[!bool_proj_pkg_R_file]
  }

  if(any(grepl(pattern = "^reexports.Rd$",
               x = list.files(path = file.path(path_pkg, "man")),
               ignore.case = TRUE))) {
    exported_funcs <- getNamespaceExports(pkg_name)

    if(length(exported_funcs) == 0L ||
       # Based on https://stackoverflow.com/a/74487073/32365738
       length(progutils::not_in(exported_funcs,
                                ls(envir = asNamespace(pkg_name)))) == 0L) {
      warn_text <- c(warn_text,
                     paste0("File 'reexports.Rd' is present in folder 'man' but no",
                            " re-exported functions were found in folder 'R'!"))
    } else {
      # Re-exported functions are ignored when looking for test files
      # corresponding to function files because these functions should be tested
      # in the package from which they are re-exported.
      R_files <- progutils::not_in(R_files, paste0(exported_funcs, ".R"))
    }
  }

  expected_test_files <- R_files
  # Programming note:
  # - This can be simplified if progutils::not_in() can handle zero-length input
  if(length(test_files_present) == 0) {
    tests_missing <- expected_test_files
    tests_extraneous <- character(0)
  } else {
    if(length(expected_test_files) > 0L) {
      tests_missing <- progutils::not_in(expected_test_files, test_files_present)
      tests_extraneous <- progutils::not_in(test_files_present, expected_test_files)
    } else {
      tests_missing <- character(0)
      tests_extraneous <- expected_test_files
    }
  }

  if(length(tests_missing) > 0L) {
    warn_text <- c(warn_text,
                   paste0("No test file found corresponding to function file ",
                          progutils::paste_quoted(sort(tests_missing))))
  }

  if(length(tests_extraneous) > 0L) {
    warn_text <- c(warn_text,
                   paste0("No function file found corresponding to test file ",
                          progutils::paste_quoted(sort(tests_extraneous))))
  }

  if(length(warn_text) > 0L) {
    warning(progutils::wrap_text(paste0(warn_text, collapse = ".\n"),
                                 ignore_newlines = FALSE))
  }

  tests_missing
}
