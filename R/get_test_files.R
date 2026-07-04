#' Get test files
#'
#' Get test files, emitting a signal if test files do not have corresponding
#' function files or vice versa.
#'
#' @inheritParams progutils::signal_text signal
#' @param testdir [character string][checkinput::is_character()] containing a
#' [valid path][checkinput::is_path()] to the directory containing tests.
#' @param pattern [character string][checkinput::is_character()] containing a
#' [regular expression][regex] used to select test files.
#' @param ignore_case `TRUE` or `FALSE`: ignore case when matching filenames to
#' `pattern`?
#'
#' @details
#' The [signal][signal_text()] indicated by argument `signal` is emitted if
#' directory `testdir`:
#'
#' - does not [exist][fs::dir_exists()]
#' - contains files that are ignored because they do not start with pattern
#'   `pattern`, are not \R files, or are template files created by
#'   [`tinytest`]( https://CRAN.R-project.org/package=tinytest)
#' - does not contain any test files
#'
#' A character string with the text of this signal is also present as attribute
#' `"info"` of the returned value.
#'
#' @returns
#' A character vector containing the found test files, which is `character(0)`
#' if no test files are found, with [attribute][attributes] `"info"` containing
#' a character string with the text of the [signal][signal_text()], which is
#' `""` if no signal is emitted.
#'
#' @family
#' functions to check tests
#'
#' @examples
#' get_test_files(testdir = fs::path_wd("inst", "tinytest"), signal = "warning")
#'
#' try(get_test_files(testdir = fs::path_wd("inst", "othertest"), signal = "warning"))
#'
#' @export
get_test_files <- function(testdir, pattern = "^test_|^test-", ignore_case = TRUE,
                           signal = c("error", "warning", "message", "quiet")) {
  signal <- match.arg(signal, several.ok = FALSE)
  stopifnot(checkinput::is_path(testdir), checkinput::is_character(pattern),
            checkinput::is_logical(ignore_case))

  pkg_name_test <- basename(dirname(dirname(testdir)))
  text_signal <- character(0)
  testdir_present <- fs::dir_exists(testdir)
  if(!testdir_present) {
    text_signal <- c(text_signal, "test directory does not exist")
    testfiles <- character(0)
  } else {
    testfiles <- basename(fs::dir_ls(path = testdir, type = "file", fail = FALSE))

    if(length(testfiles) == 0L) {
      no_test_files <- TRUE
    } else {
      no_test_files <- FALSE
      names_error_init <- !grepl(pattern = pattern, x = testfiles,
                                 ignore.case = ignore_case)
      names_error_end <- !grepl(pattern = ".R$", x = testfiles,
                                ignore.case = ignore_case)
      # Template used by 'tinytest'
      names_error_template <- testfiles %in% paste0("test_", pkg_name_test, ".R")
      names_error <- names_error_init | names_error_end | names_error_template
      if(any(names_error)) {
        text_signal <- c(
          text_signal,
          paste0("Ignoring files whose names do not start with 'pattern' (",
                 progutils::paste_quoted(pattern),
                 "), are not R files, or are template file created by 'tinytest':\n",
                 progutils::paste_quoted(testfiles[names_error])))
        testfiles <- testfiles[!names_error]
        if(length(testfiles) == 0L) {
          no_test_files <- TRUE
        }
      }
    }

    if(no_test_files) {
      text_signal <- c(text_signal,
                       "test directory exists but does not contain any testfiles")
    }
  }

  if(length(text_signal) > 0L) {
    text_signal <- paste0(text_signal, collapse = ".\n")
    text_signal <- paste(text_signal, progutils::paste_quoted(testdir), sep = ":\n")
    progutils::signal_text(text = progutils::wrap_text(
      text_signal, ignore_newlines = FALSE),
      signal = signal)
    attributes(testfiles) <- list("info" = text_signal)
  } else {
    # Not using character(0) because then grepl(pattern = "<text>",
    # x = attr(testfiles, "info"), fixed = TRUE) would become logical(0)
    attributes(testfiles) <- list("info" = "")
  }

  testfiles
}
