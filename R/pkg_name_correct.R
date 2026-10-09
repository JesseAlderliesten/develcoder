#' Check consistent use of package name
#'
#' Check that the correct package name is used in various files in the package
#' directory.
#'
#' @param pkg_name [character string][checkinput::is_character()]: the package
#' name that should be present in the checked fields and files.
#' @param pkg_dir [character string][checkinput::is_character()]: the
#' [path][checkinput::is_path()] to the directory where to look for files.
#' Subdirectories are **not** checked.
#' @param description_fields,citation_fields
#' [character vectors][checkinput::all_characters()] naming the fields of the
#' [DESCRIPTION][desc::description()] and [CITATION][cffr::cff_read_citation()]
#' files to check. Use `character(0)` to not check any fields.
#' @param warn_fields_absent `TRUE` or `FALSE`: [warn][warning()] if fields
#' indicated by `description_fields` and `citation_fields` are absent from the
#' [DESCRIPTION][desc::description()] and [CITATION][cffr::cff_read_citation()]
#' file in `pkg_dir`. Missing fields are silently ignored if
#' `warn_fields_absent` is `FALSE`.
#' @param file_patterns [character vector][checkinput::all_characters()]
#' containing regular expressions to match to file names in `pkg_dir`, using
#' case-insensitive matching. Can be `character(0)` to not check any files.
#' Hidden files (i.e., files with names starting with a dot) are **not** found.
#' @param warn_files_absent `TRUE` or `FALSE`: [warn][warning()] if files
#' matching `file_patterns` are absent from `pkg_dir`, or if `citation_fields`
#' is not `character(0)` and the [CITATION][cffr::cff_read_citation()] file is
#' absent from `pkg_dir`. Missing files are silently ignored if
#' `warn_files_absent` is `FALSE`.
#'
#' @details
#' An error is thrown if any of the checked fields or files is present but does
#' not contain the package name `pkg_name`.
#'
#' A single [DESCRIPTION][desc::description()] file should be present in
#' `pkg_dir` and it should have a `Package` field containing the package name
#' `pkg_name`, otherwise an error is thrown.
#'
#' `file_patterns` start with `\\` instead of `^` because the latter does not
#' work with the used `fs::dir_ls()` if `pkg_dir` is not `"."`.
#'
#' @returns
#' The paths to files that were present and thus checked, returned
#' [invisibly][invisible].
#'
#' @seealso
#' [match_pkg_name()], [desc::description()], [cffr::cff_read_citation()],
#' [usethis::use_news_md()], [usethis::use_pkgdown()]
#'
#' @examples
#' if(requireNamespace("withr", quietly = TRUE)) {
#' # Create a temporary directory and temporarily set the working directory to it
#' my_tempdir <- progutils::create_tempdir(prefix = "ex_pkg_name_correct")
#' pkg_name <- basename(my_tempdir)
#' withr::local_dir(new = my_tempdir)
#'
#' # Add a DESCRIPTION file
#' desc <- desc::description$new("!new")
#' path_desc <- fs::path(my_tempdir, "DESCRIPTION")
#' desc$set("Package", "toypackage")
#' desc$set("URL", "https://github.com/JesseAlderliesten/toypackage")
#' desc$set("BugReports", "https://github.com/JesseAlderliesten/toypackage/issues")
#' desc$write(file = path_desc)
#'
#' pkg_name_correct(pkg_name = "toypackage", pkg_dir = my_tempdir,
#'                  description_fields = "Package", file_patterns = "DESC")
#' # Error because field 'URL' in 'DESCRIPTION' does not give the package name
#' try(pkg_name_correct(pkg_name = "toypackage", pkg_dir = my_tempdir,
#'                      description_fields = c("Package", "URL"),
#'                      file_patterns = "DESC"))
#'
#' # Warn no 'NEWS' file is found if 'warn_files_absent' is 'TRUE'
#' pkg_name_correct(pkg_name = "toypackage", pkg_dir = my_tempdir,
#'                  description_fields = "Package",
#'                  citation_fields = character(0), file_patterns = "NEWS",
#'                  warn_files_absent = TRUE)
#' pkg_name_correct(pkg_name = "toypackage", pkg_dir = my_tempdir,
#'                  description_fields = "Package",
#'                  citation_fields = character(0), file_patterns = "NEWS",
#'                  warn_files_absent = FALSE)
#'
#' # Error because field 'Package' in 'DESCRIPTION' gives other package name
#' try(pkg_name_correct(pkg_name = "not_toypackage", pkg_dir = my_tempdir,
#'                      description_fields = "Package"))
#'
#' # Warn about missing field, not checking other files because 'file_patterns'
#' # is 'character(0)'
#' pkg_name_correct(pkg_name = "toypackage", pkg_dir = my_tempdir,
#'                  description_fields = "not_title",
#'                  file_patterns = character(0), warn_fields_absent = TRUE)
#'
#' # return to normal working directory
#' withr::deferred_run()
#' }
#'
#' @export
pkg_name_correct <- function(
    pkg_name, pkg_dir = ".",
    description_fields = c("Package", "URL", "BugReports"),
    citation_fields = c("title", "repository-code", "url"),
    file_patterns = c("\\NEWS", "\\README", "\\_pkgdown"),
    warn_fields_absent = FALSE, warn_files_absent = FALSE) {
  stopifnot(
    checkinput::is_character(pkg_name), checkinput::is_path(pkg_dir),
    checkinput::all_characters(description_fields, allow_zerolength = TRUE),
    checkinput::all_characters(citation_fields, allow_zerolength = TRUE),
    checkinput::all_characters(file_patterns, allow_zerolength = TRUE),
    checkinput::is_logical(warn_fields_absent),
    checkinput::is_logical(warn_files_absent))
  pkg_dir <- fs::path_abs(pkg_dir)

  desc_path <- character(0)
  if(length(description_fields) > 0L) {
    desc_path <- fs::path(pkg_dir, "DESCRIPTION")
    desc_path_quoted <- progutils::paste_quoted(desc_path)
    n_desc <- length(which(fs::is_file(desc_path)))

    if(n_desc != 1L) {
      stop("A single DESCRIPTION file should be present in ",
           progutils::paste_quoted(unname(pkg_dir)), " not ", n_desc)
    }

    if(!desc::desc_has_fields("Package", file = desc_path)) {
      stop("Field 'Package' not found in file ", desc_path_quoted)
    }

    .check_field_pkg_name(
      pkg_name = pkg_name, file_path = desc_path, field = "Package",
      field_content = desc::desc_get_field(
        "Package", default = NULL, file = desc_path))
    description_fields <- progutils::not_in(description_fields, "Package")

    for(field in description_fields) {
      .check_field_pkg_name(
        pkg_name = pkg_name, file_path = desc_path, field = field,
        field_content = desc::desc_get_field(
          field, default = NULL, file = desc_path),
        warn_absent = warn_fields_absent)
    }
  }

  citation_file_paths <- character(0)
  if(length(citation_fields) > 0L) {
    citation_file_paths <- unname(fs::path_abs(fs::dir_ls(
      path = pkg_dir, type = "file", regexp = "CITATION",
      fail = FALSE, ignore.case = TRUE)))

    if(!any(fs::is_file(citation_file_paths), na.rm = TRUE)) {
      if(warn_files_absent) {
        warning("No CITATION file found in ",
                progutils::paste_quoted(pkg_dir))
      }
    } else {
      # Check all citation files if there are more than one
      for(file_path in citation_file_paths) {
        for(field in citation_fields) {
          .check_field_pkg_name(
            pkg_name = pkg_name, file_path = file_path, field = field,
            field_content = cffr::cff_read(file_path)[[field]],
            warn_absent = warn_fields_absent)
        }
      }
    }
  }

  file_paths_checked <- match_pkg_name(
    pkg_name = pkg_name, pkg_dir = pkg_dir, file_patterns = file_patterns,
    warn_files_absent = warn_files_absent)

  invisible(c(desc_path, citation_file_paths, file_paths_checked))
}

#' @noRd
.check_field_pkg_name <- function(pkg_name, file_path, field, field_content,
                                  warn_absent = FALSE) {
  file_path <- fs::path_abs(file_path)
  file_path_quoted <- progutils::paste_quoted(file_path)
  field_quoted <- progutils::paste_quoted(field)

  if(is.null(field_content)) {
    if(warn_absent) {
      warning("Field ", field_quoted, " is missing from file\n",
              file_path_quoted, call. = FALSE)
    }
  } else {
    if(!grepl(pattern = pkg_name, x = field_content, fixed = TRUE)) {
      stop(progutils::wrap_text(paste0(
        "The package name ", progutils::paste_quoted(pkg_name),
        " is missing from field ", field_quoted, " of file ",
        file_path_quoted, " which is: ", field_content)))
    }
  }

  file_path
}
