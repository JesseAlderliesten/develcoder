#### Tests ####
##### Setup #####
# Create a temporary directory and temporarily set the working directory to it
my_tempdir <- progutils::create_tempdir(prefix = "test_get_testfiles")
withr::local_dir(new = my_tempdir)
pkg_name <- basename(my_tempdir)
testdir <- fs::path(my_tempdir, "inst", "tinytest")

#####  testdir missing #####
expect_warning(
  expect_equivalent(
    get_test_files(testdir = testdir, signal = "warning"),
    character(0)
  ),
  pattern = "test directory does not exist.+tinytest'$", strict = TRUE
)

##### testdir empty #####
fs::dir_create(path = testdir)
expect_warning(
  expect_equivalent(
    get_test_files(testdir = testdir, signal = "warning"),
    character(0)
  ),
  pattern = "test directory exists but does not contain any testfiles.+tinytest'$",
  strict = TRUE
)

##### testdir not empty but not containing testfiles #####
path_misc_file <- fs::path(testdir, "misc_file.R")
fs::file_create(path_misc_file)

expect_warning(
  expect_equivalent(
    get_test_files(testdir = testdir, signal = "warning"),
    character(0)
  ),
  pattern = paste0("Ignoring files whose names.+test directory exists but does",
                   " not contain any testfiles.+tinytest'$"), strict = TRUE
)

##### 'pattern' is respected #####
expect_silent(
  expect_equivalent(
    get_test_files(testdir = testdir, pattern = "misc_",
                   signal = "warning"),
    "misc_file.R"
  )
)

##### 'ignore_case' is respected #####
expect_silent(
  expect_equivalent(
    get_test_files(testdir = testdir, pattern = "MIsc_",
                   ignore_case = TRUE, signal = "warning"),
    "misc_file.R"
  )
)

expect_warning(
  expect_equivalent(
    get_test_files(testdir = testdir, pattern = "MIsc_",
                   ignore_case = FALSE, signal = "warning"),
    character(0)
  ),
  pattern = paste0("Ignoring files whose names.+test directory exists but does",
                   " not contain any testfiles.+tinytest'$"), strict = TRUE
)

##### testdir containing both ignored files and testfiles #####
fs::file_create(fs::path(testdir, "test_file.R"))
expect_warning(
  expect_equivalent(
    get_test_files(testdir = testdir, signal = "warning"),
    "test_file.R"
  ),
  pattern = "Ignoring files whose names.+tinytest'$", strict = TRUE
)

##### testdir containing only testfiles #####
fs::file_create(fs::path(testdir, "test_file2.R"))
unlink(path_misc_file)

expect_silent(
  expect_equivalent(
    get_test_files(testdir = testdir, signal = "warning"),
    c("test_file.R", "test_file2.R")
  )
)

##### Arguments that should result in an error #####
expect_warning(
  expect_error(
    get_test_files(testdir = 3, signal = "warning"),
    pattern = "is_path(testdir) is not TRUE", fixed = TRUE),
  pattern = paste0("'testdir' should be a non-empty, non-NA_character_",
                   " character string"), strict = TRUE, fixed = TRUE)

expect_warning(
  expect_error(
    get_test_files(testdir = "c", signal = "warning"),
    pattern = "is_path(testdir) is not TRUE", fixed = TRUE),
  pattern = "'testdir' should contain file separators",
  strict = TRUE, fixed = TRUE)

expect_error(
  get_test_files(testdir = testdir, ignore_case = NA, signal = "warning"),
  pattern = "is_logical(ignore_case) is not TRUE", fixed = TRUE)

expect_error(
  get_test_files(testdir = testdir, signal = "h"),
  pattern = "'arg' should be one of", fixed = TRUE)


#### Remove objects used in tests ####
unlink(my_tempdir, recursive = TRUE)
rm(my_tempdir, path_misc_file, pkg_name, testdir)
