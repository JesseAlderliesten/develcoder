#' Check if test infrastructure is present and refers to the current package
#'
#' @inheritParams progutils::signal_text signal
#' @param path_infra [character string][checkinput::is_character()] with a
#' [valid path][checkinput::is_path()]
#' to the file which determines the test infrastructure, see `Details`.
#'
#' @details
#' The default `path_infra` points to file `tinytest.R` in directory `tests` of
#' the current [working directory][getwd()], which belongs to the test
#' infrastructure of [`tinytest`]( https://CRAN.R-project.org/package=tinytest).
#' To use the test infrastructure of
#' [`testthat`](https://CRAN.R-project.org/package=testthat), use
#' `path_infra = fs::path_wd("tests", "testthat.R")`.
#'
#' The [signal][signal_text()] indicated by argument `signal` is emitted:
#' - if the package indicated in `path_infra` is not among the dependencies
#' - if the file that determines the used testing infrastructure does not exist
#' - if the file that determines the used testing infrastructure does not refer
#'   to the package in the current working directory
#'
#' @returns
#' A character vector containing a character string with the text of the
#' [signal][signal_text()], which is `""` if no signal is emitted.
#'
#' @family
#' functions to check tests
#'
#' @examples
#' # "" is returned if all is fine
#' check_test_infra(
#'   path_infra = fs::path(find.package("develcoder"), "tests", "tinytest.R"))
#'
#' # An error occurs if the test infrastructure is not present
#' try(check_test_infra(path_infra = fs::path_wd("tests", "othertest.R")))
#'
#' @export
check_test_infra <- function(path_infra = fs::path_wd("tests", "tinytest.R"),
                             signal = c("error", "warning", "message", "quiet")) {
  signal <- match.arg(signal, several.ok = FALSE)
  stopifnot(checkinput::is_path(path_infra))
  path_desc <- fs::path(dirname(dirname(path_infra)), "DESCRIPTION")
  if(!fs::is_file(path_desc)) {
    stop("No DESCRIPTION file found at ", path_desc,
         ", incorrect 'path_infra'?: ", path_infra)
  }

  test_infra <- sub(pattern = "\\.R$", replacement = "",
                    x = basename(path_infra), ignore.case = TRUE)
  pkg_name <- basename(dirname(dirname(path_infra)))
  if(pkg_name == ".") {
    stop("Could not obtain a package name, incorrect 'path_infra'?: ",
         path_infra)
  }

  text_signal <- character(0)

  if(!(test_infra %in% desc::desc_get_deps(file = path_desc)[, "package"])) {
    text_signal_deps <- paste0(
      "Add package '", test_infra, "' as suggested dependency of package ",
      progutils::paste_quoted(pkg_name), ".")
    text_signal <- c(text_signal, text_signal_deps)
  }

  if(fs::is_file(path_infra)) {
    text_infra <- readLines(con = path_infra, warn = FALSE)
    if(!any(grepl(pattern = paste0("\"", pkg_name, "\""), x = text_infra,
                  fixed = TRUE))) {
      text_signal_pkg <- paste0(
        "The file that determines the used testing infrastructure\nexists but",
        " does not refer to package ", progutils::paste_quoted(pkg_name),
        ":\n'", path_infra, "'")
      text_signal <- c(text_signal, text_signal_pkg)
    }
  } else {
    text_signal_infra <- paste0("The file that determines the used testing",
                                " infrastructure does not exist:\n", path_infra)
    text_signal <- c(text_signal, text_signal_infra)
  }

  text_signal <- paste0(text_signal, collapse = "\n")
  if(length(text_signal) > 1L || nzchar(text_signal)) {
    progutils::signal_text(
      text = progutils::wrap_text(text_signal, ignore_newlines = FALSE),
      signal = signal)
  }
  text_signal
}
