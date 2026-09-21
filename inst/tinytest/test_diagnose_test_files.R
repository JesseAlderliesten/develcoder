#### To do ####
# - Add scenario where template files for tinytest or testthat are left (should
#   result in a warning)


#### Tests ####

##### Setup #####
# Create a temporary directory and temporarily set the working directory to it
my_tempdir <- progutils::create_tempdir(prefix = "diagnose_test_files")
withr::local_dir(new = my_tempdir)
pkg_name <- basename(my_tempdir)
path_testdir <- fs::path(my_tempdir, "inst", "tinytest")

# Create a description file that does not include any dependencies
desc <- desc::description$new("!new")
path_desc <- fs::path(dirname(dirname(path_testdir)), "DESCRIPTION")
desc$write(file = path_desc)

##### testdir missing #####
expect_identical(
  diagnose_test_files(path = path_testdir),
  list(pattern = "^test_|^test-", ignore_case = TRUE,
       status_testdir = "missing", status_test_files = "missing",
       test_files = character(0), ignored_files = character(0))
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = paste0("No file determining the used testing infrastructure exists",
                   ".+tests/tinytest\\.R.+tests/testthat\\.R"),
  strict = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "None of the test directories exist.+inst/tinytest.+tests/testthat",
  strict = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "No function files found", strict = TRUE, fixed = TRUE
)

##### testdir empty #####
fs::dir_create(path = path_testdir)

expect_identical(
  diagnose_test_files(path = path_testdir),
  list(pattern = "^test_|^test-", ignore_case = TRUE,
       status_testdir = "present", status_test_files = "missing",
       test_files = character(0), ignored_files = character(0))
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = paste0("No file determining the used testing infrastructure exists",
                   ".+tests/tinytest\\.R.+tests/testthat\\.R"),
  strict = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "None of the test directories contain used test files.+inst/tinytest.+tests/testthat",
  strict = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "No function files found", strict = TRUE, fixed = TRUE
)

##### testdir not containing testfiles #####
path_misc_file <- fs::path(path_testdir, c("misc_file.R", "misc-file.R"))
fs::file_create(path_misc_file)
expect_warning(
  expect_identical(
    diagnose_test_files(path = path_testdir),
    list(pattern = "^test_|^test-", ignore_case = TRUE,
         status_testdir = "present", status_test_files = "missing",
         test_files = character(0),
         ignored_files = c("misc-file.R", "misc_file.R"))
  ), pattern = "Ignoring files.+'tinytest'.+misc-file\\.R.+misc_file\\.R",
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = paste0("No file determining the used testing infrastructure exists",
                   ".+tests/tinytest\\.R.+tests/testthat\\.R"),
  strict = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = paste0("Ignoring files that are not R files, are template files",
                   " created by 'tinytest' or\nhave names that do not start",
                   " with 'pattern' ('^test_|^test-'):\n'misc-file.R'\n'misc_file.R'"),
  strict = TRUE, fixed = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "None of the test directories contain used test files.+inst/tinytest.+tests/testthat",
  strict = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "No function files found", strict = TRUE, fixed = TRUE
)

##### testdir containing both ignored files and testfiles #####
fs::file_create(fs::path(path_testdir, "test_file.R"))
expect_warning(
  expect_identical(
    diagnose_test_files(path = path_testdir, pattern = "^test_|^test-"),
    list(pattern = "^test_|^test-", ignore_case = TRUE,
         status_testdir = "present", status_test_files = "wrong",
         test_files = "test_file.R",
         ignored_files = c("misc-file.R", "misc_file.R"))
  ), pattern = "Ignoring files.+'tinytest'.+misc-file\\.R.+misc_file\\.R",
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = paste0("No file determining the used testing infrastructure exists",
                   ".+tests/tinytest\\.R.+tests/testthat\\.R"),
  strict = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = paste0("Ignoring files that are not R files, are template files",
                   " created by 'tinytest' or\nhave names that do not start",
                   " with 'pattern' ('^test_|^test-'):\n'misc-file.R'\n'misc_file.R'"),
  strict = TRUE, fixed = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = paste0("Test files will be ignored because test infrastructure for",
                   " tinytest is missing\nor does not refer to the current package",
                   " .run 'tinytest::setup_tinytest.)' to\ncreate the test",
                   " infrastructure.:\n'test_file.R'"),
  strict = TRUE, fixed = FALSE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "None of the test directories contain used test files.+inst/tinytest.+tests/testthat",
  strict = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "No function files found", strict = TRUE, fixed = TRUE
)

##### testdir containing only testfiles, infra missing #####
fs::file_create(fs::path(path_testdir, "test_file2.R"))
unlink(path_misc_file)

expect_identical(
  diagnose_test_files(path = path_testdir, pattern = "^test_|^test-"),
  list(pattern = "^test_|^test-", ignore_case = TRUE,
       status_testdir = "present", status_test_files = "fine",
       test_files = c("test_file.R", "test_file2.R"),
       ignored_files = character(0))
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = paste0("No file determining the used testing infrastructure exists",
                   ".+tests/tinytest\\.R.+tests/testthat\\.R"),
  strict = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = paste0("Test files will be ignored because test infrastructure for",
                   " tinytest is missing\nor does not refer to the current package",
                   " .run 'tinytest::setup_tinytest.)' to\ncreate the test",
                   " infrastructure.:\n'test_file.R'"),
  strict = TRUE, fixed = FALSE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "None of the test directories contain used test files.+inst/tinytest.+tests/testthat",
  strict = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = dirname(dirname(path_testdir)), pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = "No function files found", strict = TRUE, fixed = TRUE
)


##### Arguments that should result in an error #####
# These are checked in 'test_check_tests.R'


#### Remove objects used in tests ####
unlink(my_tempdir, recursive = TRUE)
rm(desc, my_tempdir, path_desc, path_misc_file, path_testdir, pkg_name)
