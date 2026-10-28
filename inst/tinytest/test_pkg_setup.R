# Tests in this file are used to confirm code proposed in vignette 'Package
# setup': it is checked that packages have the mentioned functions and that
# functions have the mentioned arguments.

##### base #####
expect_true(all(
  c("file.path", "library") %in%
    ls(getNamespace("base"), all.names = TRUE)
))

hdb_base <- utils::hsearch_db(package = "base", types = "help")
expect_true(
  "Startup" %in%
    hdb_base$Base[, "Name"]
)

##### cffr #####
if(requireNamespace("cffr", quietly = TRUE)) {
  expect_true(
    "dependencies" %in%
      names(formals(cffr::cff_write))
  )
}

##### desc #####
if(requireNamespace("desc", quietly = TRUE)) {
  expect_true(
    "desc" %in%
      ls(getNamespace("desc"), all.names = TRUE)
  )
}

##### devtools #####
if(requireNamespace("devtools", quietly = TRUE)) {
  expect_true(all(
    c("build_readme", "document") %in%
      ls(getNamespace("devtools"), all.names = TRUE)
  ))
}

##### pkgdepends #####
if(requireNamespace("pkgdepends", quietly = TRUE)) {
  expect_true(
    "nm" %in%
      names(formals(pkgdepends::is_valid_package_name))
  )
  expect_true(
    "name" %in%
      names(formals(pkgdepends::pkg_name_check))
  )
}

##### tinytest #####
if(requireNamespace("tinytest", quietly = TRUE)) {
  expect_true(
    "pkgdir" %in%
      names(formals(tinytest::setup_tinytest))
  )
}

##### usethis #####
if(requireNamespace("usethis", quietly = TRUE)) {
  expect_true(all(
    c("edit_r_profile", "git_default_branch", "git_default_branch_rediscover",
      "git_vaccinate", "use_description", "use_github_action",
      "use_mit_license", "use_news_md", "use_package_doc", "use_pkgdown",
      "use_pkgdown_github_pages", "use_readme_rmd", "use_test") %in%
      ls(getNamespace("usethis"), all.names = TRUE)
  ))

  expect_true(
    "path" %in%
      names(formals(usethis::create_package)))
  expect_true(all(
    c("from", "to") %in%
      names(formals(usethis::git_default_branch_rename))
  ))
  expect_true(
    "message" %in%
      names(formals(usethis::use_git)))
  expect_true(
    "private" %in%
      names(formals(usethis::use_github)))

  expect_true(
    "licenses" %in%
      utils::hsearch_db(package = "usethis", types = "help")$Base[, "Name"]
  )
}

##### utils #####
expect_true(
  "url" %in%
    names(formals(utils::browseURL))
)
