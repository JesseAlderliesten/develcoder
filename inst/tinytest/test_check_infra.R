#### Create objects to use in tests ####
suggest_general <- " as suggested dependency"
suggest_tinytest <- paste0("'tinytest'", suggest_general)
suggest_testthat <- paste0("'testthat'", suggest_general)
infra_general <- "file that determines the used testing infrastructure"
infra_missing_general <- paste0(infra_general, " does not exist")
infra_missing_tinytest <- paste0(infra_missing_general, ".+tinytest.R")
infra_missing_testthat <- paste0(infra_missing_general, ".+testthat.R")
infra_wrong_general <- paste0(infra_general, "\nexists but does not refer")
infra_wrong_tinytest <- paste0(infra_wrong_general, ".+tinytest.R")
infra_wrong_testthat <- paste0(infra_wrong_general, ".+testthat.R")


#### Tests ####
##### files and dependencies missing #####
# Create a temporary directory and temporarily set the working directory to it
my_tempdir <- progutils::create_tempdir(prefix = "test_check_infra")
withr::local_dir(new = my_tempdir)
pkg_name <- basename(my_tempdir)

# Create a description file that does not include any dependencies
desc <- desc::description$new("!new")
path_desc <- fs::path(my_tempdir, "DESCRIPTION")
desc$write(file = path_desc)

# Run tests
expect_warning(
  expect_true(
    grepl(pattern = paste0(suggest_tinytest, ".+", infra_missing_tinytest),
          x = check_test_infra(fs::path(my_tempdir, "tests", "tinytest.R"),
                               signal = "warning")
    )
  ),
  pattern = paste0(suggest_tinytest, ".+", infra_missing_tinytest),
  strict = TRUE, fixed = FALSE)

expect_warning(
  expect_true(
    grepl(pattern = paste0(suggest_testthat, ".+", infra_missing_testthat),
          x = check_test_infra(fs::path(my_tempdir, "tests", "testthat.R"),
                               signal = "warning")
    )
  ),
  pattern = paste0(suggest_testthat, ".+", infra_missing_testthat),
  strict = TRUE, fixed = FALSE)

##### files and dependencies wrong #####
# Create testfiles that refer to the wrong package
testfile_tinytest <- progutils::create_file_path(
  filename = "tinytest.R", format_stamp = "",
  dir = fs::path(my_tempdir, "tests"), add_date = FALSE)
fs::file_create(testfile_tinytest)
expect_true(fs::is_file(testfile_tinytest))
writeLines(text = c("if (requireNamespace(\"tinytest\", quietly = TRUE)) {",
                    "  tinytest::test_package(\"wrongpkg\")", "}"),
           con = testfile_tinytest)

testfile_testthat <- progutils::create_file_path(
  filename = "testthat.R", format_stamp = "",
  dir = fs::path(my_tempdir, "tests"), add_date = FALSE)
fs::file_create(testfile_testthat)
expect_true(fs::is_file(testfile_testthat))
writeLines(text = c("library(testthat)", paste0("library(", pkg_name, ")"),
                    paste0("test_check(\"wrongpkg\")")),
           con = testfile_testthat)

# Add a non-relevant dependency to the DESCRIPTION file
desc <- desc::desc_set_dep(
  package = "somepkg", type = "Suggests", file = path_desc)

# Run tests again
expect_warning(
  expect_true(
    grepl(pattern = paste0(suggest_tinytest, ".+", infra_wrong_tinytest),
          x = check_test_infra(fs::path(my_tempdir, "tests", "tinytest.R"),
                               signal = "warning")
    )
  ),
  pattern = paste0(suggest_tinytest, ".+", infra_wrong_tinytest),
  strict = TRUE, fixed = FALSE)

expect_warning(
  expect_true(
    grepl(pattern = paste0(suggest_testthat, ".+", infra_wrong_testthat),
          x = check_test_infra(fs::path(my_tempdir, "tests", "testthat.R"),
                               signal = "warning")
    )
  ),
  pattern = paste0(suggest_testthat, ".+", infra_wrong_testthat),
  strict = TRUE, fixed = FALSE)

##### files missing, dependencies present #####
# Create a temporary directory and temporarily set the working directory to it
my_tempdir <- progutils::create_tempdir(prefix = "test_check_infra")
withr::local_dir(new = my_tempdir)
pkg_name <- basename(my_tempdir)

# Create a description file that includes the relevant dependencies
desc <- desc::description$new("!new")
path_desc <- fs::path(my_tempdir, "DESCRIPTION")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "tinytest", type = "Suggests", file = path_desc)
desc <- desc::desc_set_dep(
  package = "testthat", type = "Imports", file = path_desc)

# Run tests
expect_warning(
  expect_true(
    grepl(pattern = infra_missing_tinytest,
          x = check_test_infra(fs::path(my_tempdir, "tests", "tinytest.R"),
                               signal = "warning"))
  ),
  pattern = infra_missing_tinytest, strict = TRUE, fixed = FALSE)

expect_warning(
  expect_true(
    grepl(pattern = infra_missing_testthat,
          x = check_test_infra(fs::path(my_tempdir, "tests", "testthat.R"),
                               signal = "warning"))
  ),
  pattern = infra_missing_testthat, strict = TRUE, fixed = FALSE)

##### files present, dependencies missing #####
# Create file indicating which test infrastructure is used
testfile_tinytest <- progutils::create_file_path(
  filename = "tinytest.R", format_stamp = "",
  dir = fs::path(my_tempdir, "tests"), add_date = FALSE)
fs::file_create(testfile_tinytest)
expect_true(fs::is_file(testfile_tinytest))
writeLines(text = c("if (requireNamespace(\"tinytest\", quietly = TRUE)) {",
                    paste0("  tinytest::test_package(\"", pkg_name, "\")"), "}"),
           con = testfile_tinytest)

testfile_testthat <- progutils::create_file_path(
  filename = "testthat.R", format_stamp = "",
  dir = fs::path(my_tempdir, "tests"), add_date = FALSE)
fs::file_create(testfile_testthat)
expect_true(fs::is_file(testfile_testthat))
writeLines(text = c("library(testthat)", paste0("library(", pkg_name, ")"),
                    paste0("test_check(\"", pkg_name, "\")")),
           con = testfile_testthat)

# Create a description file that does not include any dependencies
desc <- desc::description$new("!new")
path_desc <- fs::path(my_tempdir, "DESCRIPTION")
desc$write(file = path_desc)

expect_warning(
  expect_true(
    grepl(pattern = suggest_tinytest,
          x = check_test_infra(fs::path(my_tempdir, "tests", "tinytest.R"),
                               signal = "warning")
    )
  ),
  pattern = suggest_tinytest, strict = TRUE, fixed = FALSE)

expect_warning(
  expect_true(
    grepl(pattern = suggest_testthat,
          x = check_test_infra(fs::path(my_tempdir, "tests", "testthat.R"),
                               signal = "warning")
    )
  ),
  pattern = suggest_testthat, strict = TRUE, fixed = FALSE)

##### files present, dependencies present #####
# Create a description file that includes the relevant dependencies
desc <- desc::description$new("!new")
path_desc <- fs::path(my_tempdir, "DESCRIPTION")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "tinytest", type = "Suggests", file = path_desc)
desc <- desc::desc_set_dep(
  package = "testthat", type = "Imports", file = path_desc)

# Run tests
expect_silent(
  expect_identical(
    check_test_infra(path_infra = testfile_tinytest, signal = "warning"),
    ""
  )
)

expect_silent(
  expect_identical(
    check_test_infra(testfile_testthat, signal = "warning"),
    ""
  )
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
  pattern = "'path_infra' should contain file separators",
  strict = TRUE, fixed = TRUE)

expect_error(
  # Path ending in 'r' that is not .r, to check that pattern is looking for
  # a literal dot instead of any character.
  check_test_infra(path_infra = fs::path("R", "develcoder")),
  pattern = "No DESCRIPTION file found", fixed = TRUE)

expect_error(
  check_test_infra(signal = "h"),
  pattern = "'arg' should be one of", fixed = TRUE)


#### Remove objects used in tests ####
unlink(my_tempdir, recursive = TRUE)
rm(desc, infra_general, infra_missing_general, infra_missing_testthat,
   infra_missing_tinytest, infra_wrong_general, infra_wrong_testthat,
   infra_wrong_tinytest, my_tempdir, path_desc,
   pkg_name, suggest_general, suggest_testthat, suggest_tinytest,
   testfile_testthat, testfile_tinytest)
