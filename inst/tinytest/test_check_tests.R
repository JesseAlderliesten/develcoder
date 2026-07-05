#### To do ####
# - Add scenarios where non-R function files are present in folder `R`
# - Add tests and ignored files in <pkg>\tests\testthat
# - Put testthat templates in <pkg>\tests\testthat
# - Put tests of test_diagnose_test_infra.R and test_diagnose_test_files.R also
#   in this file, to not have to re-create temp dir with the files again


#### Tests ####
##### Setup #####
# Create a temporary directory and temporarily set the working directory to it
my_tempdir <- progutils::create_tempdir(prefix = "check_tests")
withr::local_dir(new = my_tempdir)
pkg_name <- basename(my_tempdir)
path_testdir <- fs::path(my_tempdir, "inst", "tinytest")

##### DESCRIPTION file missing #####
expect_error(
  check_tests(path = my_tempdir),
  pattern = "No DESCRIPTION file found", fixed = TRUE)

# Create a description file that does not include any dependencies
desc <- desc::description$new("!new")
path_desc <- fs::path(my_tempdir, "DESCRIPTION")
desc$write(file = path_desc)

pattern_no_infra <- paste0("No file determining the used testing infrastructure",
                           " exists.+tinytest\\.R.+testthat\\.R")

#####  testdir missing #####
expect_warning(
  expect_identical(check_tests(path = my_tempdir), character(0)),
  pattern = pattern_no_infra, strict = TRUE)

expect_warning(
  expect_identical(check_tests(path = my_tempdir), character(0)),
  pattern = "None of the test directories exist.+tinytest.+testthat",
  strict = TRUE)

expect_warning(
  expect_identical(check_tests(path = my_tempdir), character(0)),
  pattern = "No function files found", strict = TRUE)

##### testdir empty #####
fs::dir_create(path = my_tempdir)
expect_warning(
  expect_identical(check_tests(path = my_tempdir), character(0)),
  pattern = pattern_no_infra, strict = TRUE)

expect_warning(
  expect_identical(check_tests(path = my_tempdir), character(0)),
  pattern = "None of the test directories exist.+tinytest.+testthat",
  strict = TRUE)

expect_warning(
  expect_identical(check_tests(path = my_tempdir), character(0)),
  pattern = "No function files found", strict = TRUE)

##### testdir non-empty, no testfiles #####
fs::dir_create(path = path_testdir)
path_misc_file <- fs::path(path_testdir, "misc_file.R")
fs::file_create(path_misc_file)
expect_warning(
  expect_identical(check_tests(path = my_tempdir), character(0)),
  pattern = pattern_no_infra, strict = TRUE)

expect_warning(
  expect_identical(check_tests(path = my_tempdir), character(0)),
  pattern = "Ignoring files whose names.+\\^test_\\|\\^test-.+misc_file\\.R",
  strict = TRUE)

expect_warning(
  expect_identical(check_tests(path = my_tempdir), character(0)),
  pattern = "None of the test directories contain used test files.+tinytest.+testthat",
  strict = TRUE)

expect_warning(
  expect_identical(check_tests(path = my_tempdir), character(0)),
  pattern = "No function files found", strict = TRUE)

##### 'pattern' is respected #####
expect_warning(
  expect_identical(check_tests(path = my_tempdir, pattern = "^misc_"), character(0)),
  pattern = pattern_no_infra, strict = TRUE)

expect_warning(
  expect_identical(check_tests(path = my_tempdir, pattern = "^misc_"), character(0)),
  "Test files will be ignored because test infrastructure for tinytest is missing", strict = TRUE)

expect_warning(
  expect_identical(check_tests(path = my_tempdir, pattern = "^misc_"), character(0)),
  "None of the test directories contain used test files", strict = TRUE)

expect_warning(
  expect_identical(check_tests(path = my_tempdir, pattern = "^misc_"), character(0)),
  pattern = "No function files found", strict = TRUE)

##### 'ignore_case' is respected #####
expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^MIsc_", ignore_case = TRUE),
    character(0)
  ),
  pattern = pattern_no_infra, strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^MIsc_", ignore_case = TRUE),
    character(0)
  ),
  pattern = "No function file found corresponding to test file 'misc_file.R'",
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^MIsc_", ignore_case = TRUE),
    character(0)
  ),
  pattern = "No function files found", strict = TRUE)




expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^MIsc_", ignore_case = FALSE),
    character(0)
  ),
  pattern = pattern_no_infra, strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^MIsc_", ignore_case = FALSE),
    character(0)
  ),
  pattern = "Ignoring files whose names.+\\^MIsc_.+misc_file\\.R",
  strict = TRUE)

expect_warning(
  expect_identical(check_tests(path = my_tempdir), character(0)),
  pattern = "None of the test directories contain used test files.+tinytest.+testthat",
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^MIsc_", ignore_case = FALSE),
    character(0)
  ),
  pattern = "No function files found", strict = TRUE)

##### ignored files and testfiles #####
fs::file_create(fs::path(path_testdir, "test_file.R"))
expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = pattern_no_infra, strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "Ignoring files whose names.+\\^test_\\|\\^test-.+misc_file\\.R",
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "No function files found", strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "No function file found corresponding to test file 'test_file.R'",
  strict = TRUE)

##### only testfiles #####
fs::file_create(fs::path(path_testdir, "test_file2.R"))
unlink(path_misc_file)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = pattern_no_infra, strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "No function files found", strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "No function file found corresponding to test file 'test_file.R'",
  strict = TRUE)

##### only testfiles, some function files present #####
fs::dir_create(path = fs::path(my_tempdir, "R"))
fs::file_create(fs::path(my_tempdir, "R", c("file.R", "file3.R")))

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    "test_file3.R"
  ),
  pattern = pattern_no_infra, strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "No test file found corresponding to function file 'file3.R'",
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "No function file found corresponding to test file 'test_file2.R'",
  strict = TRUE)

##### All files fine but infra wrong #####
# Set up testthat infrastructure
usethis::ui_silence(usethis::use_testthat())

# Add missing files
fs::file_create(fs::path(my_tempdir, "R", "file2.R"))
fs::file_create(fs::path(my_tempdir, "tests", "testthat", "test-file3.R"))

# Notes:
# - No warning about missing 'tinytest' test infrastructure because testthat
#   test infrastructure is present
# - Should warn about 'testthat' template file
expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    c("test_file.R", "test_file2.R", "test_file3.R")
  ),
  pattern = paste0("The file determining the used testing infrastructure",
                   " exists but does not refer\nto package ",
                   progutils::paste_quoted(pkg_name)),
  strict = TRUE, fixed = TRUE)

##### All fine #####
tinytest::setup_tinytest()


expect_silent(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  )
)


##### Arguments that should result in an error #####
expect_warning(
  expect_error(
    check_tests(path = 3),
    pattern = "is_path(path) is not TRUE", fixed = TRUE),
  pattern = paste0("'path' should be a non-empty, non-NA_character_",
                   " character string"), strict = TRUE, fixed = TRUE)

expect_warning(
  expect_error(
    check_tests(path = "c"),
    pattern = "is_path(path) is not TRUE", fixed = TRUE),
  pattern = "'path' should contain file separators",
  strict = TRUE, fixed = TRUE)

expect_error(
  check_tests(path = my_tempdir, ignore_case = NA),
  pattern = "is_logical(ignore_case) is not TRUE", fixed = TRUE)


#### Remove objects used in tests ####
unlink(my_tempdir, recursive = TRUE)
rm(my_tempdir, path_misc_file, path_testdir, pkg_name)
