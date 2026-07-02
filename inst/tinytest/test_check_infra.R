#### Create objects to use in tests ####
suggest_tinytest <- "Add package 'tinytest' as suggested dependency"
suggest_testthat <- "Add package 'testthat' as suggested dependency"
infra_general <- paste0("file that determines the used testing infrastructure",
                        " does not exist")
infra_tinytest <- paste0(infra_general, ".+tinytest.R")
infra_testthat <- paste0(infra_general, ".+testthat.R")


#### Set up local directory ####
my_tempdir <- progutils::create_tempdir(prefix = "test_check_infra")
pkg_name <- basename(my_tempdir)

path_desc <- fs::path(my_tempdir, "DESCRIPTION")
withr::local_dir(new = my_tempdir)
desc <- desc::description$new("!new")
desc$write(file = path_desc)


#### Tests ####
##### Missing files and missing dependencies #####
expect_warning(
  expect_true(
    grepl(pattern = paste0(suggest_tinytest, ".+", infra_tinytest),
          x = check_test_infra(fs::path(my_tempdir, "tests", "tinytest.R"),
                               signal = "warning")
    )
  ),
  pattern = paste0(suggest_tinytest, ".+", infra_tinytest),
  strict = TRUE, fixed = FALSE)

##### Missing files #####
desc <- desc::desc_set_dep(package = "tinytest", type = "Suggests")

expect_warning(
  expect_true(
    grepl(pattern = infra_tinytest,
          x = check_test_infra(fs::path(my_tempdir, "tests", "tinytest.R"),
                               signal = "warning"))
  ),
  pattern = infra_tinytest, strict = TRUE, fixed = FALSE)

expect_warning(
  expect_true(
    grepl(pattern = paste0(suggest_testthat, ".+", infra_testthat),
          x = check_test_infra(fs::path(my_tempdir, "tests", "testthat.R"),
                               signal = "warning"))
  ),
  pattern = paste0(suggest_testthat, ".+", infra_testthat),
  strict = TRUE, fixed = FALSE)

desc <- desc::desc_set_dep(package = "testthat", type = "Suggests")

# Create file indicating which test infrastructure is used
testfile_tinytest <- progutils::create_file_path(
  filename = "tinytest.R", format_stamp = "",
  dir = fs::path(my_tempdir, "tests"), add_date = FALSE)
fs::file_create(testfile_tinytest)
expect_true(fs::is_file(testfile_tinytest))
writeLines(text = c("if (requireNamespace(\"tinytest\", quietly = TRUE)) {",
                    "  tinytest::test_package(\"testpkg\")", "}"),
           con = testfile_tinytest)

expect_warning(
  expect_true(
    grepl(pattern = "exists but does not refer to package",
          x = check_test_infra(fs::path(my_tempdir, "tests", "tinytest.R"),
                               signal = "warning"))
  ),
  pattern = "exists but does not refer to package", strict = TRUE, fixed = FALSE)

writeLines(text = c("if (requireNamespace(\"tinytest\", quietly = TRUE)) {",
                    paste0("  tinytest::test_package(\"", pkg_name, "\")"), "}"),
           con = testfile_tinytest)

expect_silent(
  expect_identical(
    check_test_infra(fs::path(my_tempdir, "tests", "tinytest.R"),
                     signal = "warning"),
    "")
)

expect_warning(
  expect_true(
    grepl(pattern = infra_testthat,
          x = check_test_infra(fs::path(my_tempdir, "tests", "testthat.R"),
                               signal = "warning"))
  ),
  pattern = infra_testthat, strict = TRUE, fixed = FALSE)

# Create file indicating which test infrastructure is used
testfile_testthat <- progutils::create_file_path(
  filename = "testthat.R", format_stamp = "",
  dir = fs::path(my_tempdir, "tests"), add_date = FALSE)
fs::file_create(testfile_testthat)
expect_true(fs::is_file(testfile_testthat))
writeLines(text = c("library(testthat)", paste0("library(", pkg_name, ")"),
                    paste0("test_check(\"", pkg_name, "\")")),
           con = testfile_testthat)

expect_silent(
  expect_identical(
    check_test_infra(fs::path(my_tempdir, "tests", "testthat.R"),
                     signal = "warning"),
    "")
)

##### Arguments that should result in an error #####
expect_warning(
  expect_error(
    check_test_infra(path_infra = 3),
    pattern = "is_path(path_infra) is not TRUE", fixed = TRUE),
  pattern = paste0("'path_infra' should be a non-empty, non-NA_character_",
                   " character string"), strict = TRUE, fixed = TRUE)

expect_warning(
  expect_error(
    check_test_infra(path_infra = "c"),
    pattern = "is_path(path_infra) is not TRUE", fixed = TRUE),
  pattern = "'path_infra' should contain file separators", strict = TRUE, fixed = TRUE)

expect_error(
  # Path ending in 'r' that is not .r, to check that pattern is looking for
  # a literal dot instead of any character.
  check_test_infra(path_infra = fs::path("R", "develcoder")),
  pattern = "'path_infra' should have at least three levels of directories",
  fixed = TRUE)

expect_error(
  check_test_infra(signal = "h"),
  pattern = "'arg' should be one of", fixed = TRUE)


#### Remove objects used in tests ####
# Notes:
# - Unlinking does NOT work (because of the call to withr::local_dir()?) but
#   without removing, tinytest::test_all() writes the DESCRIPTION file to the
#   test-directory (i.e., develcoder\inst\tinytest) that is NOT removed, not
#   even when R is shut down.
rm(desc, my_tempdir, path_desc, infra_general, infra_testthat, infra_tinytest,
   pkg_name, suggest_testthat, suggest_tinytest, testfile_testthat,
   testfile_tinytest)
