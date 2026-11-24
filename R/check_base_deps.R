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
#' A package can occur more than once within a single type of dependency (e.g.,
#' `Imports`, `Depends`, `Suggests`) to indicate a range, e.g.,
#' `<pkg A> (>= 3.6.0)` and `<pkg A> (<= 4.4.0)`. However, each package should
#' be listed in only one of the types of dependencies, otherwise an error is
#' thrown.
#'
#' It is **not** required to declare version numbers for the
#' [base](https://cran.r-project.org/doc/FAQ/R-FAQ.html#Add_002don-packages-in-R)
#' or
#' [recommended](https://cran.r-project.org/doc/FAQ/R-FAQ.html#Add_002don-packages-from-CRAN)
#' packages. If version numbers are declared, they should contain at least a
#' major and minor level. [Warnings][warning] are issued if different minimum
#' versions are declared for those packages, or if they declare minimum versions
#' that differ from the declared earliest version of \R if that is present.
#'
#' If `"R"` is listed in the DESCRIPTION file, it should:
#'
#' - be in field `"Depends"`
#' - declare at least one minimum version number
#' - **not** declare a version earlier than any declared minimum versions of the
#'   base or recommended packages
#' - contain at least a major and minor level, e.g., `R (>= 4.0)` or `R (>= 4.1)`
#' - use `0` as patch level (i.e., as third digit in the version number) if it
#'   is present: `R (>= 4.4.0)` or `R (>= 4.4)` instead of `R (>= 4.4.1)`,
#'   otherwise a warning is issued.
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
#' - `package` giving the package name or `"R"`
#' - `version` giving the version specification, e.g., `">= 4.0.0"`, with `*`
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
#'     if(requireNamespace("usethis", quietly = TRUE)) {
#'       usethis::use_package(
#'         "R", type = "Depends", min_version = "4.0.0")
#'       (check_base_deps(tempdir_example))
#'     }
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
#'     try(check_base_deps(tempdir_example)) # Error
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

  if(requireNamespace("tools",
                      versionCheck = list(op = ">=", version = "4.4.0"),
                      quietly = TRUE)) {
    names_std <- unlist(tools::standard_package_names(), use.names = FALSE)
  } else {
    names_std <- c(
      "base", "tools", "utils", "grDevices", "graphics", "stats", "datasets",
      "methods", "grid", "splines", "stats4", "tcltk", "compiler", "parallel",
      "MASS", "lattice", "Matrix", "nlme", "survival", "boot", "cluster",
      "codetools", "foreign", "KernSmooth", "rpart", "class", "nnet", "spatial",
      "mgcv")
  }

  deps <- desc::desc_get_deps(file = path_desc)
  bool_dep_R <- deps[, "package"] == "R"
  bool_deps_std <- deps[, "package"] %in% names_std
  deps_out <- deps[bool_dep_R | bool_deps_std, , drop = FALSE]
  rownames(deps_out) <- NULL

  types_per_pkg <- lapply(X = split(x = deps, f = deps[, "package"]),
                          FUN = function(x) {unique(x[, "type"])})
  bool_pkg_types <- lengths(types_per_pkg) > 1L
  if(any(bool_pkg_types)) {
    stop("Each package should be listed in only one of the types of",
         "\ndependencies. The following packages are listed in multiple types:\n",
         progutils::vect_to_char(types_per_pkg)
    )
  }

  n_dep_R <- length(which(bool_dep_R))
  min_base_version <- NULL
  if(n_dep_R > 0L) {
    dep_R <- deps[bool_dep_R, , drop = FALSE]
    if(any(deps[bool_dep_R, "type"] != "Depends")) {
      stop("Dependency 'R' should be in field 'Depends' of the DESCRIPTION",
           " file, not in field ",
           progutils::paste_quoted(unique(deps[bool_dep_R, "type"])))
    }

    if(!any(grepl(pattern = ">=", x = deps[bool_dep_R, "version"], fixed = TRUE))) {
      stop("Indicate a minimum version number for 'R' if you list",
           " it in the DESCRIPTION\nfile, e.g., 'R (>= 4.6)'. Currently the",
           " following versions are indicated:\n",
           progutils::paste_quoted(deps[bool_dep_R, "version"]))
    }

    if(n_dep_R > 1L) {
      warning("Dependency 'R' occurs ", progutils::vect_to_char(n_dep_R),
              " times in the DESCRIPTION file, with the following versions:\n",
              progutils::paste_quoted(deps[bool_dep_R, "version"]))
    }

    # '.split_dependencies()' and '.split_op_version()' are not yet exported
    # from 'tools' (but see https://bugs.r-project.org/show_bug.cgi?id=18639)
    base_version_no_ops <- gsub("[[:space:]]|<|=|>", replacement = "",
                                x = deps[bool_dep_R, "version"])
    bool_minor_missing <- is.na(
      package_version(base_version_no_ops, strict = FALSE)$minor)
    if(any(bool_minor_missing)) {
      stop("Include at least a major and minor level in version numbers for R,",
           " e.g., '4.0':\n",
           progutils::paste_quoted(dep_R[bool_minor_missing, "version"]))
    }

    patch_value <- package_version(base_version_no_ops, strict = FALSE)$patch
    bool_patch_nonzero <- !is.na(patch_value) & patch_value != 0L
    if(any(bool_patch_nonzero)) {
      warning("It is good practice to only use '0' as patch level for",
              " dependencies\non R. You might want to adjust the following",
              " versions:\n",
              progutils::vect_to_char(dep_R[bool_patch_nonzero, "version"]))
    }
    min_base_version <- min(as.numeric_version(base_version_no_ops))
  }

  if(any(bool_deps_std)) {
    std_deps <- deps[bool_deps_std, , drop = FALSE]
    rownames(std_deps) <- NULL

    if("base" %in% std_deps[, "package"]) {
      stop("Do not list package 'base' as dependency in the DESCRIPTION file.",
           " List 'R' with a\nminimum version in field 'Depends' if you want",
           " to indicate a minimum version of R.")
    }

    # desc::desc_get_deps() uses version '*' for non-versioned dependencies.
    # Those can be ignored here when checking for versions that are too late or
    # that differ from each other
    std_deps_versioned <- std_deps[std_deps[, "version"] != "*", , drop = FALSE]
    if(nrow(std_deps_versioned) > 0L) {
      if(!is.null(min_base_version)) {
        # '.split_dependencies()' and '.split_op_version()' are not yet exported
        # from 'tools' (but see https://bugs.r-project.org/show_bug.cgi?id=18639)
        std_deps_versioned_no_ops <- gsub("[[:space:]]|<|=|>", replacement = "",
                                          x = std_deps_versioned[, "version"])

        bool_minor_missing_std <- is.na(
          package_version(std_deps_versioned_no_ops, strict = FALSE)$minor)
        if(any(bool_minor_missing_std)) {
          stop("Include at least a major and minor level in version numbers",
               " for base or recommended packages, e.g., '4.0':\n",
               progutils::paste_quoted(
                 std_deps_versioned[bool_minor_missing_std, "version"]))
        }

        bool_R_early <- package_version(
          std_deps_versioned_no_ops, strict = FALSE) > min_base_version
        if(any(bool_R_early)) {
          std_deps_late <- std_deps_versioned[bool_R_early, "version"]
          names(std_deps_late) <- std_deps_versioned[bool_R_early, "package"]
          stop("The DESCRIPTION file lists a declared minimum version of 'R'",
               " that\nis earlier than declared minimum versions of base or",
               " recommended packages:\nR ",
               progutils::vect_to_char(dep_R[, "version"]), " with ",
               progutils::vect_to_char(std_deps_late, collapse = "; ")
          )
        }
      }

      if(length(unique(std_deps_versioned[, "version"])) > 1L) {
        std_deps_diff_version <- std_deps_versioned[, "version"]
        names(std_deps_diff_version) <- std_deps_versioned[, "package"]
        warning("Base or recommended packages in the DESCRIPTION\nfile declare",
                " different minimum versions:\n",
                progutils::vect_to_char(std_deps_diff_version, collapse = "; "))
      }
    }
  }

  invisible(deps_out)
}
