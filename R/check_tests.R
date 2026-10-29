#' Check Tests
#'
#' Check if testing infrastructure is present and refers to the current package,
#' and if function files have a corresponding test file and vice versa.
#'
#' @inheritParams diagnose_test_files
#' @param path [character string][checkinput::is_character()] containing a
#' valid [path][checkinput::is_path()] to the folder with the package of which
#' the testing infrastructure and test files should be checked. The default is
#' the [working directory][getwd()].
#' @param test_vignettes `TRUE` or `FALSE`: should vignettes have a
#' corresponding test file?
#'
#' @details
#' This function looks for \R files starting with pattern `pattern` in folders
#' `inst/tinytest` and `tests/testthat` in the directory indicated by `path`,
#' which is where [**tinytest**](https://CRAN.R-project.org/package=tinytest)
#' and [**testthat**](https://CRAN.R-project.org/package=testthat) place their
#' test files, respectively.
#'
#' It is checked that testing infrastructure referring to the current package is
#' present. Test files are ignored if the corresponding test infrastructure is
#' missing or wrong, with a warning.
#'
#' It is checked that all test files have a corresponding `.R` function file in
#' folder `R` or an `.Rmd` vignette in folder `vignettes`. It is also checked
#' that all function files and, if `test_vignettes` is `TRUE`, all vignettes,
#' have a corresponding test file. Function files of re-exported functions are
#' ignored when looking for corresponding test files because those functions
#' should be tested in the package from which they are re-exported.
#'
#' Warnings are issued if:
#'
#' - none of the test directories [exist][fs::dir_exists()]
#' - none of the test directories contain test files
#' - test directories contain files that are ignored because their names do
#'   **not** start with pattern `pattern`, are not \R files, or are template
#'   files created by [**tinytest**](https://CRAN.R-project.org/package=tinytest)
#'   or [**testthat**](https://testthat.r-lib.org/)
#' - test directories used by **tinytest** or **testthat** contain test files
#'   while their test architecture is not set up
#' - test directories contain test files without corresponding function file in
#'   folder `R` or vignette in folder `vignettes`
#' - folder `R` contains function files without corresponding test files
#' - folder `R` contains files that are not \R files
#' - folder `R` does not contain any function files
#' - folder `vignettes` contains files that are not `.Rmd` files
#' - folder `vignettes` contains `.Rmd` files without corresponding test files
#'   while `test_vignettes` is `TRUE`
#' - files `tests\tinytest.R` or `tests\testthat.R` determining which test
#'   infrastructure is used are present but do **not** refer to the current
#'   package, or the packages **tinytest** and **testthat** are missing from the
#'   dependencies of the tested package
#' - file `tests\tinytest.R` nor `tests\testthat.R` is present
#' - file `man\reexports.Rd` is present but no re-exported functions are present
#'   in folder `R`
#'
#' @returns
#' If all is fine: `character(0)`. Otherwise, a list containing components
#' `missing` and `extraneous` containing character vectors with the names of
#' function files for which no used test file is present, and the names of test
#' files for which no function file is present, respectively.
#'
#' @seealso
#' Section
#' [Set up testing infrastructure](
#' https://jessealderliesten.github.io/develcoder/articles/pkg_setup.html#set-up-testing-infrastructure)
#' in vignette *Package setup* and section
#' [Add tests](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html#add-tests)
#' in vignette *Package development*: `vignette("pkg_setup", package = "develcoder")`
#' and `vignette("pkg_devel", package = "develcoder")`.
#'
#' Other functions to check tests:
#' [check_tests()], [diagnose_test_files()], [diagnose_test_infra()]
#'
#' @examples
#' path_develcoder <- find.package("develcoder")
#' # test files are present
#' check_tests(path = path_develcoder) # character(0)
#'
#' if(requireNamespace("withr", quietly = TRUE)) {
#' # warnings: test infrastructure, directories,
#' # and function files not present
#' tempdir_example <- progutils::create_tempdir(
#'   prefix = "check_tests")
#' withr::with_dir(new = tempdir_example, {
#'   # Set up a package without testing infrastructure
#'   desc <- desc::description$new("!new")
#'   desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
#'   check_tests(path = tempdir_example)
#' })
#' # Remove temporary directory
#' unlink(tempdir_example, recursive = TRUE)
#' }
#'
#' @export
check_tests <- function(path = getwd(),
                        pattern = "^test_|^test-",
                        ignore_case = TRUE,
                        test_vignettes = FALSE) {
  stopifnot(checkinput::is_path(path),
            checkinput::is_character(pattern),
            checkinput::is_logical(ignore_case),
            checkinput::is_logical(test_vignettes))

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
            progutils::paste_quoted(files_tinytest$test_files, collapse = "\n"))
    files_tinytest$ignored_files <- c(files_tinytest$ignored_files,
                                      files_tinytest$test_files)
    files_tinytest$test_files <- character(0)
  }

  files_testthat <- diagnose_test_files(
    path = path_testthat, pattern = pattern, ignore_case = ignore_case)
  if(length(files_testthat$test_files) > 0L && infra_testthat$status != "fine") {
    warning(warn_ignore_p1, " testthat ", warn_ignore_p2,
            " 'usethis::use_testthat()' ", warn_ignore_p3,
            progutils::paste_quoted(files_testthat$test_files, collapse = "\n"))
    files_testthat$ignored_files <- c(files_testthat$ignored_files,
                                      files_testthat$test_files)
    files_testthat$test_files <- character(0)
  }

  tests_present <- c(files_tinytest$test_files, files_testthat$test_files)
  bool_dir_missing <- c(files_tinytest$status_testdir,
                        files_testthat$status_testdir) == "missing"
  all_paths <- c(path_tinytest, path_testthat)

  if(all(bool_dir_missing)) {
    warning("None of the test directories exist:\n",
            progutils::paste_quoted(all_paths, collapse = "\n"))
  } else {
    if(length(tests_present) == 0L) {
      warning("None of the test directories contain used test files:\n",
              progutils::paste_quoted(all_paths, collapse = ",\n"))
    }
  }

  path_R <- fs::path(path, "R")
  R_files <- list.files(path_R)
  bool_not_R <- !endsWith(x = R_files, suffix = ".R")
  if(any(bool_not_R)) {
    warning("Ignoring non-R files in folder '", path_R, "':\n",
            progutils::paste_quoted(R_files[bool_not_R], collapse = ",\n"))
    R_files <- R_files[!bool_not_R]
  }

  bool_proj_pkg_R_file <- grepl(pattern = ".package.R$", x = R_files)
  if(any(bool_proj_pkg_R_file)) {
    R_files <- R_files[!bool_proj_pkg_R_file]
  }

  files_man <- list.files(path = file.path(path, "man"),
                          pattern = "^Reexports.Rd$",
                          ignore.case = TRUE)
  if(length(files_man) > 0L) {
    # Based on https://stackoverflow.com/a/74487073/32365738
    reexported_funcs <- progutils::not_in(getNamespaceExports(pkg),
                                          ls(envir = asNamespace(pkg)))
    if(length(reexported_funcs) == 0L) {
      warning("File 'reexports.Rd' is present in folder 'man' but no",
              " re-exported functions were found in folder 'R'!")
    } else {
      # Re-exported functions are ignored when looking for test files
      # corresponding to function files because these functions should
      # be tested in the package from which they are re-exported.
      R_files <- progutils::not_in(R_files, paste0(reexported_funcs, ".R"))
    }
  }

  expected_tests_R <- character(0L)
  missing_tests_R <- character(0L)
  if(length(R_files) == 0L) {
    warning("No function files found in folder '", path_R, "'.")
  } else {
    expected_tests_R <- R_files
    missing_tests_R <- progutils::not_in(
      expected_tests_R,
      sub(pattern = pattern, replacement = "", x = tests_present,
          ignore.case = ignore_case))
    if(length(missing_tests_R) > 0L) {
      warning("No test file found corresponding to function file\n",
              progutils::paste_quoted(missing_tests_R, collapse = ",\n")
      )
    }
  }

  path_vignettes <- fs::path(path, "vignettes")
  vignette_files <- character(0L)
  expected_tests_vignettes <- character(0L)
  missing_tests_vignettes <- character(0L)
  if(fs::dir_exists(path_vignettes)) {
    vignette_files <- basename(
      fs::dir_ls(path = path_vignettes, type = "file", fail = FALSE))
    bool_not_Rmd <- !endsWith(x = vignette_files, suffix = ".Rmd")
    if(any(bool_not_Rmd)) {
      warning("Ignoring non-Rmd files in folder '", path_vignettes, "':\n",
              progutils::paste_quoted(vignette_files[bool_not_Rmd],
                                      collapse = ",\n"))
      vignette_files <- vignette_files[!bool_not_Rmd]
    }
    if(length(vignette_files) == 0L) {
      warning("No vignettes found in folder '", path_vignettes, "'.")
    } else {
      expected_tests_vignettes <- sub(
        pattern = "[.]Rmd", replacement = ".R", x = vignette_files,
        fixed = TRUE)
      if(test_vignettes) {
        bool_missing_tests_vignettes <- progutils::not_in(
          expected_tests_vignettes,
          sub(pattern = pattern, replacement = "", x = tests_present,
              ignore.case = ignore_case),
          value = FALSE)
        missing_tests_vignettes <- vignette_files[bool_missing_tests_vignettes]
        if(length(missing_tests_vignettes) > 0L) {
          warning("No test file found corresponding to vignette\n",
                  progutils::paste_quoted(missing_tests_vignettes,
                                          collapse = ",\n")
          )
        }
      }
    }
  }

  extraneous_tests <- progutils::not_in(
    sub(pattern = pattern, replacement = "", x = tests_present,
        ignore.case = ignore_case),
    c(expected_tests_R, expected_tests_vignettes)
  )
  if(length(extraneous_tests) > 0L) {
    warning("No function file or vignette found corresponding to test file\n",
            progutils::paste_quoted(extraneous_tests, collapse = ",\n"))
  }

  list(missing = c(missing_tests_R, missing_tests_vignettes),
       extraneous = extraneous_tests)
}
