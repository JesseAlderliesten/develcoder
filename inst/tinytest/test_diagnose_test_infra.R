#### Tests ####
##### files and deps missing #####
# Create a temporary directory and temporarily set the working directory to it
my_tempdir_p1 <- progutils::create_tempdir(prefix = "diagnose_test_infra")
withr::local_dir(new = my_tempdir_p1)
pkg_name <- basename(my_tempdir_p1)
path_tinytest <- fs::path(my_tempdir_p1, "tests", "tinytest.R")
path_testthat <- fs::path(my_tempdir_p1, "tests", "testthat.R")

# Create a description file that does not include any dependencies
desc <- desc::description$new("!new")
path_desc <- fs::path(my_tempdir_p1, "DESCRIPTION")
desc$write(file = path_desc)

# Run tests
expect_silent(
  expect_identical(
    diagnose_test_infra(path = path_tinytest),
    list(name = "tinytest", status = "missing", dependency = "missing")
  )
)

expect_silent(
  expect_identical(
    diagnose_test_infra(path = path_testthat),
    list(name = "testthat", status = "missing", dependency = "missing")
  )
)

##### files and deps wrong #####
# Create testfiles that refer to the wrong package
testfile_tinytest <- fs::path(fs::dir_create(fs::path(my_tempdir_p1, "tests")),
                              "tinytest.R")
fs::file_create(testfile_tinytest)
expect_true(fs::is_file(testfile_tinytest))
writeLines(text = c("if (requireNamespace(\"tinytest\", quietly = TRUE)) {",
                    "  tinytest::test_package(\"wrongpkg\")", "}"),
           con = testfile_tinytest)

testfile_testthat <- fs::path(fs::dir_create(fs::path(my_tempdir_p1, "tests")),
                              "testthat.R")
fs::file_create(testfile_testthat)
expect_true(fs::is_file(testfile_testthat))
writeLines(text = c("library(testthat)", paste0("library(", pkg_name, ")"),
                    paste0("test_check(\"wrongpkg\")")),
           con = testfile_testthat)

# Add a non-relevant dependency to the DESCRIPTION file
desc <- desc::desc_set_dep(
  package = "test", type = "Suggests", file = path_desc)

# Run tests again
expect_warning(
  expect_identical(
    diagnose_test_infra(path = path_tinytest),
    list(name = "tinytest", status = "wrong", dependency = "missing")
  ), pattern = paste0("testing infrastructure exists.+", pkg_name),
  strict = TRUE)

expect_warning(
  expect_identical(
    diagnose_test_infra(path = path_tinytest),
    list(name = "tinytest", status = "wrong", dependency = "missing")
  ), pattern = "package 'tinytest'", strict = TRUE, fixed = TRUE)

expect_warning(
  expect_identical(
    diagnose_test_infra(path = path_testthat),
    list(name = "testthat", status = "wrong", dependency = "missing")
  ), pattern = paste0("testing infrastructure exists.+", pkg_name),
  strict = TRUE)

expect_warning(
  expect_identical(
    diagnose_test_infra(path = path_testthat),
    list(name = "testthat", status = "wrong", dependency = "missing")
  ), pattern = "package 'testthat'", strict = TRUE, fixed = TRUE)

##### files missing, deps present #####
# Create a temporary directory and temporarily set the working directory to it
my_tempdir_p2 <- progutils::create_tempdir(prefix = "diagnose_test_infra")
withr::local_dir(new = my_tempdir_p2)
pkg_name <- basename(my_tempdir_p2)
path_tinytest <- fs::path(my_tempdir_p2, "tests", "tinytest.R")
path_testthat <- fs::path(my_tempdir_p2, "tests", "testthat.R")

# Create a description file that includes the relevant dependencies
desc <- desc::description$new("!new")
path_desc <- fs::path(my_tempdir_p2, "DESCRIPTION")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "tinytest", type = "Suggests", file = path_desc)
desc <- desc::desc_set_dep(
  package = "testthat", type = "Imports", file = path_desc)

# Run tests
expect_identical(
  diagnose_test_infra(path = path_tinytest),
  list(name = "tinytest", status = "missing", dependency = "fine")
)

expect_identical(
  diagnose_test_infra(path = path_testthat),
  list(name = "testthat", status = "missing", dependency = "fine")
)

##### files present, deps missing #####
# Create file indicating which test infrastructure is used
testfile_tinytest <- fs::path(fs::dir_create(fs::path(my_tempdir_p2, "tests")),
                              "tinytest.R")
fs::file_create(testfile_tinytest)
expect_true(fs::is_file(testfile_tinytest))
writeLines(text = c("if (requireNamespace(\"tinytest\", quietly = TRUE)) {",
                    paste0("  tinytest::test_package(\"", pkg_name, "\")"), "}"),
           con = testfile_tinytest)

testfile_testthat <- fs::path(fs::dir_create(fs::path(my_tempdir_p2, "tests")),
                              "testthat.R")
fs::file_create(testfile_testthat)
expect_true(fs::is_file(testfile_testthat))
writeLines(text = c("library(testthat)", paste0("library(", pkg_name, ")"),
                    paste0("test_check(\"", pkg_name, "\")")),
           con = testfile_testthat)

# Create a description file that does not include any dependencies
desc <- desc::description$new("!new")
path_desc <- fs::path(my_tempdir_p2, "DESCRIPTION")
desc$write(file = path_desc)

expect_warning(
  expect_identical(
    diagnose_test_infra(path = path_tinytest),
    list(name = "tinytest", status = "fine", dependency = "missing")
  ), pattern = "package 'tinytest'", strict = TRUE, fixed = TRUE)

expect_warning(
  expect_identical(
    diagnose_test_infra(path = path_testthat),
    list(name = "testthat", status = "fine", dependency = "missing")
  ), pattern = "package 'testthat'", strict = TRUE, fixed = TRUE)

##### files present, deps present #####
# Create a description file that includes the relevant dependencies
desc <- desc::description$new("!new")
path_desc <- fs::path(my_tempdir_p2, "DESCRIPTION")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "tinytest", type = "Suggests", file = path_desc)
desc <- desc::desc_set_dep(
  package = "testthat", type = "Imports", file = path_desc)

# Run tests
expect_identical(
  diagnose_test_infra(path = path_tinytest),
  list(name = "tinytest", status = "fine", dependency = "fine")
)

expect_identical(
  diagnose_test_infra(path = path_testthat),
  list(name = "testthat", status = "fine", dependency = "fine")
)

##### Arguments that should result in an error #####
# These are checked in 'test_check_tests.R'


#### Remove objects used in tests ####
unlink(c(my_tempdir_p1, my_tempdir_p2), recursive = TRUE)
rm(desc, my_tempdir_p1, my_tempdir_p2, path_desc, path_testthat, path_tinytest,
   pkg_name, testfile_testthat, testfile_tinytest)
