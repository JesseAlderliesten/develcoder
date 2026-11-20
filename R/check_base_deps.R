#' Check base dependencies
#'
#' @param path [character string][checkinput::is_character()] containing a
#' valid [path][checkinput::is_path()] to the folder with the package of which
#' the [DESCRIPTION][desc::description()] file should be checked. The default is
#' the [working directory][getwd()].
#'
#' @details
#' If `"R"` is present in the DESCRIPTION file to indicate a minimum version
#' dependency on \R, it should be in field `"Depends"`, occur only once, and
#' declare a minimum version number, otherwise an [error][stop()] is thrown.
#'
#' Package [`base`] should **not** be listed in the DESCRIPTION file: it is
#' always loaded. An error is thrown if it is present. If you want to indicate
#' a minimum version dependency on \R, list `"R"` in field `"Depends"` to do so,
#' e.g., through
#'
#' `usethis::use_package("R", type = "Depends", min_version = "4.0.0")` or
#' `desc::desc_set_dep("R", type = "Depends", version = ">= 4.0.0")`.
#'
#' The
#' [base](https://cran.r-project.org/doc/FAQ/R-FAQ.html#Add_002don-packages-in-R)
#' and
#' [recommended](https://cran.r-project.org/doc/FAQ/R-FAQ.html#Add_002don-packages-from-CRAN)
#' packages do **not** have to declare a minimum version number, but if they
#' declare minimum versions, [warnings][warning] are issued if they declare
#' different minimum versions, or declare minimum versions that differ from the
#' declared minimum version of \R if that is present.
#'
#' @returns
#' The [dependencies][desc::desc_get_deps()] found in the DESCRIPTION file,
#' returned [invisibly][invisible].
#'
#' @examples
#' if(requireNamespace("withr", quietly = TRUE)) {
#'   tempdir_example <- progutils::create_tempdir(prefix = "check_base_deps")
#'
#'   withr::with_dir(new = tempdir_example, {
#'   # Set up a package
#'   desc <- desc::description$new("!new")
#'   desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
#'
#'   # R without minimum version in 'Depends'
#'   desc <- desc::desc_set_dep(
#'     package = "R", type = "Depends")
#'   try(check_base_deps(tempdir_example))
#'
#'   # R with minimum version in 'Depends'
#'   desc <- desc::desc_set_dep(
#'     package = "R", type = "Depends", version = ">= 4.0.0")
#'   (check_base_deps(tempdir_example))
#'
#'   # Add package 'tools' (a 'base' package)
#'   # with a different minimum version
#'   desc <- desc::desc_set_dep(
#'     package = "tools", type = "Depends", version = ">= 4.1.0")
#'   # A warning that versions differ:
#'   (check_base_deps(tempdir_example))
#'   })
#'   # Remove temporary directory
#'   unlink(tempdir_example, recursive = TRUE)
#' }
#'
#' @export
check_base_deps <- function(path = ".") {
  stopifnot(checkinput::is_path(path, require_sep = FALSE))

  path_desc <- fs::path(path, "DESCRIPTION")
  if(!fs::is_file(path_desc)) {
    stop("No DESCRIPTION file found at ", progutils::paste_quoted(path_desc),
         ", incorrect 'path'?:\n", path)
  }

  deps <- desc::desc_get_deps(file = path_desc)
  if("base" %in% deps[, "package"]) {
    stop("Do not list 'base' as dependency in the DESCRIPTION file. List 'R'",
         " with a\nminimum version in field 'Depends' if you want to indicate",
         " a minimum version of R.")
  }

  dep_R <- deps[deps[, "package"] == "R", , drop = FALSE]
  nrow_dep_R <- nrow(dep_R)
  if(nrow_dep_R > 1L) {
    stop("Dependency 'R' should occur only once in the DESCRIPTION file, not ",
         progutils::vect_to_char(nrow_dep_R), " times")
  }

  base_version <- NULL
  if(nrow_dep_R > 0L) {
    if(dep_R[, "type"] != "Depends") {
      wrong_type <- dep_R[, "type"]
      stop("Dependency 'R' should be in field 'Depends' of the DESCRIPTION",
           " file, not in field ", progutils::paste_quoted(wrong_type))
    }

    if(!grepl(pattern = ">=", x = dep_R[, "version"], fixed = TRUE)) {
      print(dep_R)
      stop("Indicate a minimum version number for 'R' if you\nlist",
           " it in the DESCRIPTION file, e.g., 'R (>= 4.6)'.")
    }
    base_version <- dep_R[, "version"]
  }

  names_std <- unlist(tools::standard_package_names(), use.names = FALSE)
  bool_deps_std <- deps[, "package"] %in% names_std
  if(any(bool_deps_std)) {
    deps_in_std <- deps[bool_deps_std, , drop = FALSE]
    rownames(deps_in_std) <- NULL

    # desc::desc_get_deps() uses version '*' for non-versioned dependencies.
    bool_versioned <- deps_in_std[, "version"] != "*"
    if(any(bool_versioned)) {
      if(!is.null(base_version)) {
        bool_unequal <- bool_versioned & deps_in_std[, "version"] != base_version
        if(any(bool_unequal)) {
          print(deps_in_std[bool_unequal, , drop = FALSE])
          warning("The DESCRIPTION file lists base or recommended packages",
                  " with minimum\nversions that differ from the declared",
                  " minimum version of 'R':\n",
                  progutils::paste_quoted(deps_in_std[bool_unequal, "package"]))
        }
      }

      if(length(unique(deps_in_std[bool_versioned, "version"])) > 1L) {
        print(deps_in_std[bool_versioned, , drop = FALSE])
        warning("The DESCRIPTION file lists base or recommended packages with",
                " different declared minimum versions:\n",
                progutils::paste_quoted(deps_in_std[bool_versioned, "package"]))
      }
    }
  }

  invisible(deps)
}
