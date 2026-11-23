#' Check base dependencies
#'
#' @param path [character string][checkinput::is_character()] containing a
#' valid [path][checkinput::is_path()] to the folder with the package of which
#' the [DESCRIPTION][desc::description()] file should be checked. The default is
#' the [working directory][getwd()].
#'
#' @details
#' Package [`base`] should **not** be listed in the DESCRIPTION file: it is
#' always loaded. See the `Examples` how to list a dependency on \R using
#' [usethis::use_package()].
#'
#' Each package should be listed in only one of the types of dependencies (e.g.,
#' `Imports`, `Depends`, `Suggests`), otherwise an error is thrown. A package
#' can occur more than once within a single type of dependency to indicate a
#' range, e.g., `<pkg A> (>= 3.6.0)` and `<pkg A> (<= 4.4.0)`.
#'
#' If version numbers are declared for the
#' [base](https://cran.r-project.org/doc/FAQ/R-FAQ.html#Add_002don-packages-in-R)
#' or
#' [recommended](https://cran.r-project.org/doc/FAQ/R-FAQ.html#Add_002don-packages-from-CRAN)
#' packages (it is **not** required to do so), [warnings][warning] are issued if
#' they declare different minimum versions, or if they declare minimum versions
#' that differ from the declared earliest version of \R if that is present.
#'
#' If `"R"` is listed in the DESCRIPTION file, it should:
#'
#' - be in field `"Depends"`
#' - declare at least one minimum version number
#' - **not** declare a version earlier than any declared minimum versions of the
#'   base or recommended packages
#' - use `0` as patch level (e.g., as third digit in the version number:
#'   `R (<= 4.4.0)` instead of `R (<= 4.4.1)`) or omit the patch level
#'   altogether, otherwise a warning is issued.
#'
#' @returns
#' A [data frame][data.frame()] with the [dependencies][desc::desc_get_deps()]
#' on \R, base packages and recommended packages as listed in the DESCRIPTION
#' file, returned [invisibly][invisible]. A zero-row data frame is returned if
#' such dependencies are not present.
#'
#' The data frame has the following columns:
#'
#' - `type` giving the type of dependency, e.g., `Imports`, `Depends`, `Suggests`
#' - `package` with `"R"` or the package name
#' - `version` giving the version specification, e.g., `">= 4.0.0"`, with `"*"`
#'   if no version is declared
#'
#' @examples
#' if(requireNamespace("withr", quietly = TRUE)) {
#'   tempdir_example <- progutils::create_tempdir(
#'     prefix = "check_base_deps")
#'
#'   withr::with_dir(new = tempdir_example, {
#'     # Create a DESCRIPTION file
#'     desc <- desc::description$new("!new")
#'     desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
#'
#'     # Use package 'usethis' to add R with
#'     # a minimum version in 'Depends'
#'     usethis::use_package(
#'       "R", type = "Depends", min_version = "4.0.0")
#'     (check_base_deps(tempdir_example))
#'
#'     # Create a new DESCRIPTION file
#'     desc <- desc::description$new("!new")
#'     desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
#'
#'     # Use package 'desc' to add R with
#'     # a minimum version in 'Depends'
#'     desc <- desc::desc_set_dep(
#'       "R", type = "Depends", version = ">= 4.0.0")
#'     (check_base_deps(tempdir_example))
#'
#'     # Add package 'checkinput'
#'     desc <- desc::desc_set_dep("checkinput", type = "Depends")
#'     # 'checkinput' is not among the returned packages
#'     # because it is not a 'base' or 'recommended' package.
#'     (check_base_deps(tempdir_example))
#'
#'     # Add package 'tools' (a 'base' package)
#'     # with an earlier minimum version than 'R'
#'     desc <- desc::desc_set_dep(
#'       "tools", type = "Depends", version = ">= 3.6.0")
#'     (check_base_deps(tempdir_example)) # silent
#'
#'     # Add package 'utils' (a 'base' package)
#'     # with a later minimum version than 'R'
#'     desc <- desc::desc_set_dep(
#'       "utils", type = "Depends", version = ">= 4.1.0")
#'     # An error that the declared minimum version of R is
#'     # earlier than the declared minimum version of 'utils':
#'     try(check_base_deps(tempdir_example))
#'
#'     # A new DESCRIPTION file without dependencies
#'     desc <- desc::description$new("!new")
#'     desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
#'     # Silently returns a zero-row data frame
#'     (check_base_deps(tempdir_example))
#'
#'     # R without minimum version in 'Depends'
#'     desc <- desc::description$new("!new")
#'     desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
#'     desc <- desc::desc_set_dep("R", type = "Depends")
#'     try(check_base_deps(tempdir_example))
#'   })
#'
#'   # Remove temporary directory
#'   unlink(tempdir_example, recursive = TRUE)
#' }
#'
#' @export
check_base_deps <- function(path = ".") {
  stopifnot(checkinput::is_path(path, require_sep = FALSE))

  path_desc <- fs::path(path, "DESCRIPTION")
  if(!fs::is_file(path_desc)) {
    stop("Incorrect 'path'? No DESCRIPTION file found at\n",
         progutils::paste_quoted(path_desc))
  }

  deps <- desc::desc_get_deps(file = path_desc)
  if("base" %in% deps[, "package"]) {
    stop("Do not list 'base' as dependency in the DESCRIPTION file. List 'R'",
         " with a\nminimum version in field 'Depends' if you want to indicate",
         " a minimum version of R.")
  }

  bool_dep_R <- deps[, "package"] == "R"
  dep_R <- deps[bool_dep_R, , drop = FALSE]
  nrow_dep_R <- nrow(dep_R)
  min_base_version <- NULL
  if(nrow_dep_R > 0L) {
    if(any(dep_R[, "type"] != "Depends")) {
      stop("Dependency 'R' should be in field 'Depends' of the DESCRIPTION",
           " file, not in field ",
           progutils::paste_quoted(unique(dep_R[, "type"])))
    }

    bool_min_R <- grepl(pattern = ">=", x = dep_R[, "version"], fixed = TRUE)
    if(!any(bool_min_R)) {
      print(dep_R)
      stop("Indicate a minimum version number for 'R' if you\nlist",
           " it in the DESCRIPTION file, e.g., 'R (>= 4.6)'.")
    }

    if(nrow_dep_R > 1L) {
      print(dep_R)
      warning("Dependency 'R' occurs ",  progutils::vect_to_char(nrow_dep_R),
              " times in the DESCRIPTION file!")
    }

    # '.split_dependencies()' and '.split_op_version()' are not yet exported
    # from 'tools' (but see https://bugs.r-project.org/show_bug.cgi?id=18639)
    base_version_no_ops <- gsub("[[:space:]]|<|=|>", replacement = "",
                                x = dep_R[, "version"])
    min_base_version <- min(as.numeric_version(base_version_no_ops))
    bool_patch_nonzero <- package_version(base_version_no_ops)$patch != 0L
    if(any(bool_patch_nonzero)) {
      warning("It is good practice to only use '0' as patch level for",
              " dependencies\non R. You might want to adjust the following",
              " versions:\n",
              progutils::vect_to_char(dep_R[bool_patch_nonzero, "version"]))
    }
  }

  if(utils::packageVersion("tools") >= "4.4.0") {
    names_std <- unlist(tools::standard_package_names(), use.names = FALSE)
  } else {
    names_std <- c(
      "base", "tools", "utils", "grDevices", "graphics", "stats", "datasets",
      "methods", "grid", "splines", "stats4", "tcltk", "compiler", "parallel",
      "MASS", "lattice", "Matrix", "nlme", "survival", "boot", "cluster",
      "codetools", "foreign", "KernSmooth", "rpart", "class", "nnet", "spatial",
      "mgcv")
  }

  bool_deps_std <- deps[, "package"] %in% names_std
  if(any(bool_deps_std)) {
    deps_in_std <- deps[bool_deps_std, , drop = FALSE]
    rownames(deps_in_std) <- NULL

    # desc::desc_get_deps() uses version '*' for non-versioned dependencies.
    bool_versioned <- deps_in_std[, "version"] != "*"
    if(any(bool_versioned)) {

      if(!is.null(min_base_version)) {
        # '.split_dependencies()' and '.split_op_version()' are not yet exported
        # from 'tools' (but see https://bugs.r-project.org/show_bug.cgi?id=18639)
        deps_std_version <- as.numeric_version(
          gsub("[[:space:]]|<|=|>", replacement = "", x = deps_in_std[, "version"]))

        # To do:
        # - This leads to the error 'invalid version specification ‘*’' if
        #   versioned and non-versioned base-packages are mixed in the
        #   DESCRIPTION file
        bool_R_early <- bool_versioned & deps_std_version > min_base_version
        if(any(bool_R_early)) {
          print(deps_in_std[bool_R_early, , drop = FALSE])
          stop("The DESCRIPTION file lists a declared minimum version of 'R'",
               " that is\nearlier than declared minimum versions of base or",
               " recommended packages:\n",
               progutils::paste_quoted(deps_in_std[bool_R_early, "package"]))
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

  pkg_types <- lapply(X = split(x = deps, f = deps[, "package"]),
                      FUN = function(x) {length(unique(x[, "type"]))})
  if(any(unlist(pkg_types) > 1L)) {
    print(deps)
    stop("Each package should be listed in only one of the types of dependencies.")
  }

  deps_out <- deps[bool_dep_R | bool_deps_std, , drop = FALSE]
  rownames(deps_out) <- NULL
  invisible(deps_out)
}
