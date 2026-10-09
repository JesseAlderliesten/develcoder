#' Match package name
#'
#' Match a package name to the content of files.
#'
#' @inheritParams pkg_name_correct
#'
#' @returns
#' The paths to the files that were checked, returned [invisibly][invisible].
#'
#' @seealso
#' [pkg_name_correct()], [usethis::use_news_md()], [usethis::use_pkgdown()]
#'
#' @examples
#' match_pkg_name(pkg_name = "develcoder", warn_files_absent = FALSE)
#' match_pkg_name(pkg_name = "develcoder", warn_files_absent = TRUE)
#'
#' @export
match_pkg_name <- function(pkg_name, pkg_dir = ".",
                           file_patterns = c("\\NEWS", "\\README", "\\_pkgdown"),
                           warn_files_absent = FALSE) {
  stopifnot(
    checkinput::is_character(pkg_name), checkinput::is_path(pkg_dir),
    checkinput::all_characters(file_patterns, allow_zerolength = TRUE),
    checkinput::is_logical(warn_files_absent))
  pkg_dir <- fs::path_abs(pkg_dir)

  # Not using list.files() because that also returns directories (even though
  # 'include.dirs' is FALSE by default) because 'recursive' is also FALSE.
  # Hidden files are not found.
  all_files <- as.character(fs::dir_ls(path = pkg_dir, type = "file", fail = FALSE))

  bool_match <- rep(FALSE, length(all_files))
  for(pattern in file_patterns) {
    bool_match_temp <- grepl(pattern = pattern, x = basename(all_files), ignore.case = TRUE)
    if(warn_files_absent && !any(bool_match_temp)) {
      warning("No files found matching pattern ",
              progutils::paste_quoted(pattern))
    }
    bool_match[which(bool_match_temp)] <- TRUE
  }

  file_paths <- all_files[bool_match]

  match_content_pattern <- function(file_paths, pattern) {
    any(grepl(pattern = pattern, x = readLines(con = file_paths, warn = FALSE),
              fixed = TRUE))
  }

  bool_name_found <- vapply(X = file_paths, FUN = match_content_pattern,
                            FUN.VALUE = logical(1), pattern = pkg_name,
                            USE.NAMES = FALSE)

  if(!all(bool_name_found)) {
    stop(progutils::wrap_text(paste0(
      "The package name ", progutils::paste_quoted(pkg_name),
      " is missing from file\n",
      progutils::paste_quoted(file_paths[!bool_name_found], collapse = "\n"))))
  }

  invisible(file_paths)
}
