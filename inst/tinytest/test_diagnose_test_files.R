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

##### DESCRIPTION file missing #####
expect_error(
  diagnose_test_files(path = path_testdir),
  pattern = "No DESCRIPTION file found", fixed = TRUE)

# Create a description file that does not include any dependencies
desc <- desc::description$new("!new")
path_desc <- fs::path(dirname(dirname(path_testdir)), "DESCRIPTION")
desc$write(file = path_desc)

#####  testdir missing #####
expect_identical(
  diagnose_test_files(path = path_testdir),
  list(pattern = "^test_|^test-", ignore_case = TRUE,
       status_testdir = "missing", status_test_files = "missing",
       test_files = character(0), ignored_files = character(0))
)

##### testdir empty #####
fs::dir_create(path = path_testdir)
expect_identical(
  diagnose_test_files(path = path_testdir),
  list(pattern = "^test_|^test-", ignore_case = TRUE,
       status_testdir = "present", status_test_files = "missing",
       test_files = character(0), ignored_files = character(0))
)

##### testdir not empty but not containing testfiles #####
path_misc_file <- fs::path(path_testdir, "misc_file.R")
fs::file_create(path_misc_file)
expect_warning(
  expect_identical(
    diagnose_test_files(path = path_testdir),
    list(pattern = "^test_|^test-", ignore_case = TRUE,
         status_testdir = "present", status_test_files = "missing",
         test_files = character(0), ignored_files = "misc_file.R")
  ), pattern = "Ignoring files.+misc_file.R", strict = TRUE)

##### 'pattern' is respected #####
expect_identical(
  diagnose_test_files(path = path_testdir, pattern = "^misc_"),
  list(pattern = "^misc_", ignore_case = TRUE,
       status_testdir = "present", status_test_files = "fine",
       test_files = "misc_file.R", ignored_files = character(0))
)

##### 'ignore_case' is respected #####
expect_identical(
  diagnose_test_files(path = path_testdir, pattern = "^MIsc_",
                      ignore_case = TRUE),
  list(pattern = "^MIsc_", ignore_case = TRUE,
       status_testdir = "present", status_test_files = "fine",
       test_files = "misc_file.R", ignored_files = character(0))
)

expect_warning(
  expect_identical(
    diagnose_test_files(path = path_testdir, pattern = "^MIsc_",
                        ignore_case = FALSE),
    list(pattern = "^MIsc_", ignore_case = FALSE,
         status_testdir = "present", status_test_files = "missing",
         test_files = character(0), ignored_files = "misc_file.R")
  ), pattern = "Ignoring files.+misc_file.R", strict = TRUE)

##### testdir containing both ignored files and testfiles #####
fs::file_create(fs::path(path_testdir, "test_file.R"))
expect_warning(
  expect_identical(
    diagnose_test_files(path = path_testdir, pattern = "^test_|^test-"),
    list(pattern = "^test_|^test-", ignore_case = TRUE,
         status_testdir = "present", status_test_files = "wrong",
         test_files = "test_file.R", ignored_files = "misc_file.R")
  ), pattern = "Ignoring files.+misc_file.R", strict = TRUE)

##### testdir containing only testfiles #####
fs::file_create(fs::path(path_testdir, "test_file2.R"))
unlink(path_misc_file)

expect_identical(
  diagnose_test_files(path = path_testdir, pattern = "^test_|^test-"),
  list(pattern = "^test_|^test-", ignore_case = TRUE,
       status_testdir = "present", status_test_files = "fine",
       test_files = c("test_file.R", "test_file2.R"),
       ignored_files = character(0))
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
  diagnose_test_files(path = path_testdir, ignore_case = NA),
  pattern = "is_logical(ignore_case) is not TRUE", fixed = TRUE)


#### Remove objects used in tests ####
unlink(my_tempdir, recursive = TRUE)
rm(desc, my_tempdir, path_desc, path_misc_file, path_testdir, pkg_name)
