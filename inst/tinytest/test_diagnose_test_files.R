#### Tests ####
##### Setup #####
# Create a temporary directory and temporarily set the working directory to it
my_tempdir <- progutils::create_tempdir(prefix = "test_get_testfiles")
withr::local_dir(new = my_tempdir)
pkg_name <- basename(my_tempdir)
testdir <- fs::path(my_tempdir, "inst", "tinytest")

#####  testdir missing #####
expect_identical(
  diagnose_test_files(path = testdir),
  list(pkg = pkg_name, path = testdir, pattern = "^test_|^test-",
       ignore_case = TRUE, testdir = "missing", status_test_files = "missing",
       test_files = character(0), ignored_files = character(0))
)

##### testdir empty #####
fs::dir_create(path = testdir)
expect_identical(
  diagnose_test_files(path = testdir),
  list(pkg = pkg_name, path = testdir, pattern = "^test_|^test-",
       ignore_case = TRUE, testdir = "present", status_test_files = "missing",
       test_files = character(0), ignored_files = character(0))
)

##### testdir not empty but not containing testfiles #####
path_misc_file <- fs::path(testdir, "misc_file.R")
fs::file_create(path_misc_file)
expect_identical(
  diagnose_test_files(path = testdir),
  list(pkg = pkg_name, path = testdir, pattern = "^test_|^test-",
       ignore_case = TRUE, testdir = "present", status_test_files = "missing",
       test_files = character(0), ignored_files = "misc_file.R")
)

##### 'pattern' is respected #####
expect_identical(
  diagnose_test_files(path = testdir, pattern = "^misc_"),
  list(pkg = pkg_name, path = testdir, pattern = "^misc_",
       ignore_case = TRUE, testdir = "present", status_test_files = "fine",
       test_files = "misc_file.R", ignored_files = character(0))
)

##### 'ignore_case' is respected #####
expect_identical(
  diagnose_test_files(path = testdir, pattern = "^MIsc_", ignore_case = TRUE),
  list(pkg = pkg_name, path = testdir, pattern = "^MIsc_",
       ignore_case = TRUE, testdir = "present", status_test_files = "fine",
       test_files = "misc_file.R", ignored_files = character(0))
)

expect_identical(
  diagnose_test_files(path = testdir, pattern = "^MIsc_", ignore_case = FALSE),
  list(pkg = pkg_name, path = testdir, pattern = "^MIsc_",
       ignore_case = FALSE, testdir = "present", status_test_files = "missing",
       test_files = character(0), ignored_files = "misc_file.R")
)

##### testdir containing both ignored files and testfiles #####
fs::file_create(fs::path(testdir, "test_file.R"))
expect_identical(
  diagnose_test_files(path = testdir, pattern = "^test_|^test-"),
  list(pkg = pkg_name, path = testdir, pattern = "^test_|^test-",
       ignore_case = TRUE, testdir = "present", status_test_files = "wrong",
       test_files = "test_file.R", ignored_files = "misc_file.R")
)

##### testdir containing only testfiles #####
fs::file_create(fs::path(testdir, "test_file2.R"))
unlink(path_misc_file)

expect_identical(
  diagnose_test_files(path = testdir, pattern = "^test_|^test-"),
  list(pkg = pkg_name, path = testdir, pattern = "^test_|^test-",
       ignore_case = TRUE, testdir = "present", status_test_files = "fine",
       test_files = c("test_file.R", "test_file2.R"), ignored_files = character(0))
)

##### Arguments that should result in an error #####
expect_warning(
  expect_error(
    diagnose_test_files(path = 3),
    pattern = "is_path(path) is not TRUE", fixed = TRUE),
  pattern = paste0("'path' should be a non-empty, non-NA_character_",
                   " character string"), strict = TRUE, fixed = TRUE)

expect_warning(
  expect_error(
    diagnose_test_files(path = "c"),
    pattern = "is_path(path) is not TRUE", fixed = TRUE),
  pattern = "'path' should contain file separators",
  strict = TRUE, fixed = TRUE)

expect_error(
  diagnose_test_files(path = testdir, ignore_case = NA),
  pattern = "is_logical(ignore_case) is not TRUE", fixed = TRUE)


#### Remove objects used in tests ####
unlink(my_tempdir, recursive = TRUE)
rm(my_tempdir, path_misc_file, pkg_name, testdir)
