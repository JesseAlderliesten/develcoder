# Tests in this file are used to confirm code proposed in vignette 'Package
# development': it is checked that packages have the mentioned functions and
# that functions have the mentioned arguments.


#### base ####
expect_true(all(
  c(".libPaths", ".Platform", "attach", "basename", "detach", "find.package",
    "getRversion", "getwd", "invisible", "library", "loadedNamespaces",
    "make.names", "names", "on.exit", "options", "read.dcf", "requireNamespace",
    "sort", "stopifnot", "Sys.getlocale", "unloadNamespace") %in%
    ls(getNamespace("base"), all.names = TRUE)
))

expect_true(all(c("fixed", "pattern", "x") %in% names(formals(base::grepl))))
expect_true("versionCheck" %in% names(formals(base::loadNamespace)))
expect_true("quietly" %in% names(formals(base::requireNamespace)))

hdb_base <- utils::hsearch_db(package = "base", types = "help")
expect_true(":::" %in% hdb_base$Aliases[, "Alias"])
expect_true(all(c("Comparison", "locales") %in% hdb_base$Base[, "Name"]))

expect_true("file.sep" %in% names(.Platform))

#### BiocCheck ####
if(requireNamespace("BiocCheck", quietly = TRUE)) {
  expect_true(all(
    c("callr", "package") %in% names(formals(BiocCheck::BiocCheck))
  ))
}

#### cffr ####
if(requireNamespace("cffr", quietly = TRUE)) {
  expect_true("dependencies" %in% names(formals(cffr::cff_write)))
}

#### checkinput ####
if(requireNamespace("checkinput", quietly = TRUE)) {
  expect_true("all_names" %in% ls(getNamespace("checkinput"), all.names = TRUE))

  expect_true("x" %in% names(formals(checkinput::all_names)))
  expect_true("allow_NA" %in% names(formals(checkinput::is_logical)))
}

#### checktor ####
if(requireNamespace("checktor", quietly = TRUE)) {
  expect_true(all(
    c("checktor", "lab_description_function_quotes", "lab_format_names",
      "lab_title_starts_with_article") %in%
      ls(getNamespace("checktor"), all.names = TRUE)
  ))
}

#### codetools ####
if(requireNamespace("codetools", quietly = TRUE)) {
  expect_true(all(
    c("pack", "...") %in%
      names(formals(codetools::checkUsagePackage))
  ))

  expect_true(all(
    c("all", "suppressParamAssigns") %in%
      names(formals(codetools::checkUsage))
  ))
}

#### desc ####
if(requireNamespace("desc", quietly = TRUE)) {
  expect_true(all(
    c("desc", "desc_get_deps", "desc_normalize") %in%
      ls(getNamespace("desc"), all.names = TRUE)
  ))
}

#### develcoder ####
if(requireNamespace("develcoder", quietly = TRUE)) {
  expect_true(all(
    c("check_tests", "diagnose_test_files", "pkg_name_correct") %in%
      ls(getNamespace("develcoder"), all.names = TRUE)
  ))
}

#### devtools ####
if(requireNamespace("devtools", quietly = TRUE)) {
  ns_devtools <- ls(getNamespace("devtools"), all.names = TRUE)

  expect_true(all(
    c("check_mac_release", "check_win_release", "document", "load_all",
      "loaded_packages", "release_checks", "run_examples", "test") %in%
      ns_devtools
  ))

  if(utils::packageVersion("devtools") >= "2.5.0") {
    expect_true("check_doc_fields" %in% ns_devtools)
  }

  expect_true(all(
    c("env_vars", "manual", "remote") %in%
      names(formals(devtools::check))
  ))

  expect_true(all(
    c("build_vignettes", "quick", "upgrade") %in%
      names(formals(devtools::install))
    ))

  expect_true(all(
    c("pkg", "bioconductor") %in% names(formals(devtools::revdep))
    ))
  expect_true("pkg" %in% names(formals(devtools::revdep_maintainers)))
}

#### fs ####
if(requireNamespace("fs", quietly = TRUE)) {
  expect_true("dir_exists" %in% ls(getNamespace("fs"), all.names = TRUE))
}

#### goodpractice ####
if(requireNamespace("goodpractice", quietly = TRUE)) {
  expect_true(all(
    c("all_check_groups", "all_checks", "failed_checks", "goodpractice") %in%
      ls(getNamespace("goodpractice"), all.names = TRUE)
  ))
  expect_true(all(
    c("checks", "path") %in% names(formals(goodpractice::goodpractice))
  ))

  goodpractice_all_checks <- goodpractice::all_checks()
  expect_true(all(
    c("complexity_function_length", "covr", "cyclocomp",
      "lintr_line_length_linter", "lintr_outer_negation_linter",
      "lintr_scalar_in_linter", "tidyverse_brace_linter",
      "tidyverse_function_left_parentheses_linter",
      "tidyverse_indentation_linter", "tidyverse_line_length_linter",
      "tidyverse_object_name_linter",
      "tidyverse_spaces_left_parentheses_linter", "tidyverse_test_file_names",
      "tidyverse_whitespace_linter"
    ) %in% goodpractice_all_checks
  ))
  expect_true(
    all(c("rcmdcheck", "urlchecker") %in% goodpractice::all_check_groups())
  )
}

#### graphics ####
expect_true(
  "no.readonly" %in% names(formals(graphics::par))
)

#### knitr ####
if(requireNamespace("knitr", quietly = TRUE)) {
  expect_true(all(
    c("get_engine", "knit_engines") %in%
      ls(getNamespace("knitr"), all.names = TRUE)
  ))
  expect_true(all(c("get", "set") %in% names(knitr::knit_engines)))
}

#### pkgdown ####
if(requireNamespace("pkgdown", quietly = TRUE)) {
  expect_true(all(
    c("build_article", "build_reference", "build_site") %in%
      ls(getNamespace("pkgdown"), all.names = TRUE)
  ))
}


#### pkgload ####
if(requireNamespace("pkgload", quietly = TRUE)) {
  expect_true("is_dev_package" %in% ls(getNamespace("pkgload"), all.names = TRUE))
}

#### pkgstats ####
if(requireNamespace("pkgstats", quietly = TRUE)) {
  expect_true(all(
    c("ctags_install", "pkgstats") %in% ls(getNamespace("pkgstats"), all.names = TRUE)
  ))

  expect_true(all(
    c("noerror", "quiet") %in% names(formals(pkgstats::ctags_test))
  ))
}

#### progutils ####
if(requireNamespace("progutils", quietly = TRUE)) {
  expect_true(all(
    c("create_dir", "create_tempdir", "not_in", "reorder_levels") %in%
      ls(getNamespace("progutils"), all.names = TRUE)
  ))
}


#### sessioncheck ####
if(requireNamespace("sessioncheck", quietly = TRUE)) {
  expect_true(all(
    c("sessioncheck", "sessionstate") %in% ls(getNamespace("sessioncheck"), all.names = TRUE)
  ))
}

#### roxygen2 ####
if(requireNamespace("roxygen2", quietly = TRUE)) {
  expect_true("roxygenise" %in% ls(getNamespace("roxygen2"), all.names = TRUE))
}

#### sessioninfo ####
if(requireNamespace("sessioninfo", quietly = TRUE)) {
  expect_true("session_info" %in% ls(getNamespace("sessioninfo"), all.names = TRUE))
}

#### tinytest ####
if(requireNamespace("tinytest", quietly = TRUE)) {
  expect_true(all(
    c("expect_equal", "expect_silent", "expect_true", "run_test_file", "test_all") %in%
      ls(getNamespace("tinytest"), all.names = TRUE)
  ))

  expect_true(all(
    c("...", "pattern") %in% names(formals(tinytest::expect_error))
  ))

  expect_true(all(
    c("...", "pattern", "strict") %in% names(formals(tinytest::expect_warning))
  ))
}


#### tools ####
expect_true(all(
  c("check_packages_in_dir", "CRAN_check_details", "CRAN_check_issues",
    "CRAN_check_results", "dependsOnPkgs", "Rd2txt") %in%
    ls(getNamespace("tools"), all.names = TRUE)
))

expect_true(all(c("dir", "verbose") %in% names(formals(tools::check_package_urls))))

expect_true(all(c("recursive", "reverse", "which") %in% names(formals(tools::package_dependencies))))
expect_true("package" %in% names(formals(tools::pkgVignettes)))

if(utils::packageVersion("tools") >= "4.4.0") {
  expect_true(
    "standard_package_names" %in% ls(getNamespace("tools"), all.names = TRUE)
  )
  expect_identical(
    c("base", "recommended"), names(tools::standard_package_names())
  )
}

#### usethis ####
if(requireNamespace("usethis", quietly = TRUE)) {
  expect_true(all(
    c("create_package", "use_mit_license", "use_news_md", "use_package_doc",
      "use_pkgdown", "use_pkgdown_github_pages", "use_r", "use_readme_rmd") %in%
      ls(getNamespace("usethis"), all.names = TRUE)
  ))

  expect_true(all(
    c("package", "remote", "type") %in% names(formals(usethis::use_dev_package))
  ))

  hdb_usethis <- utils::hsearch_db(package = "usethis", types = "help")
  expect_true("licenses" %in% hdb_usethis$Base[, "Name"])

  expect_true(all(c("fun", "package") %in% names(formals(usethis::use_import_from))))
  expect_false("min_version" %in% names(formals(usethis::use_import_from)))
  expect_true(all(c("package", "type", "min_version") %in% names(formals(usethis::use_package))))
  expect_true(all(c("push", "which") %in% names(formals(usethis::use_version))))
  expect_true("title" %in% names(formals(usethis::use_vignette)))
}

#### utils ####
expect_true(all(
  c("download.packages", "example", "packageVersion", "sessionInfo", "vignette") %in%
    ls(getNamespace("utils"), all.names = TRUE)
))
expect_true("dir" %in% names(formals(utils::aspell_package_Rd_files)))
expect_true("dir" %in% names(formals(utils::aspell_package_vignettes)))
expect_true("package" %in% names(formals(utils::browseVignettes)))
expect_true("fields" %in% names(formals(utils::installed.packages)))
expect_true(all(c("fields", "pkg") %in% names(formals(utils::packageDescription))))
expect_true("pkg" %in% names(formals(utils::packageVersion)))
expect_true("package" %in% names(formals(utils::vignette)))

expect_true(
  all.equal(getRversion(), utils::packageVersion(pkg = "base"),
            check.attributes = FALSE)
)
