#### To do ####
# - Include out-commented tests
# - Include tests that are only headings


#### Create objects to use in tests ####
pattern_desc <- "No DESCRIPTION file found"
pattern_ignored <- paste0("Ignoring files that are not R files, are template",
                          " files created by ")
pattern_no_test_file <- "No test file found corresponding to function file "
error_path <- "'path' should be a non-empty, non-NA_character_ character string"
error_path_sep <- "'path' should contain file separators"
error_not_path <- "is_path(path) is not TRUE"

#### setup ####

##### Create temporary directory #####
# Create a temporary directory and temporarily set the working directory to it
my_tempdir <- progutils::create_tempdir(prefix = "check_tests")
pkg_name <- basename(my_tempdir)
path_tinytest <- fs::path(my_tempdir, "inst", "tinytest")
path_testthat <- fs::path(my_tempdir, "tests", "testthat")
withr::local_dir(new = my_tempdir)

##### DESCRIPTION file missing #####
expect_error(
  check_tests(path = my_tempdir),
  pattern = pattern_desc, fixed = TRUE)

expect_error(
  diagnose_test_infra(path = path_tinytest),
  pattern = pattern_desc, fixed = TRUE)

expect_error(
  diagnose_test_files(path = path_tinytest),
  pattern = pattern_desc, fixed = TRUE)

##### Add DESCRIPTION file #####
desc <- desc::description$new("!new")
path_desc <- fs::path(my_tempdir, "DESCRIPTION")
# Suppress warning caused by underscore in package name
suppressWarnings(desc$set("Package", pkg_name))
desc$write(file = path_desc)

##### function files #####
path_R <- fs::path(my_tempdir, "R")
fs::dir_create(path_R)
tinytest_funcs <- c("some_func_tinytest.R", "other_func_tinytest.R")
testthat_funcs <- c("some_func_testthat.R", "other_func_testthat.R")
test_funcs <- c(tinytest_funcs, testthat_funcs)
other_funcs <- sort(
  test_funcs[startsWith(x = test_funcs, prefix = "other_func_")])
fs::file_create(fs::path(path_R, test_funcs))
path_other_funcs <- fs::file_create(fs::path(path_R, other_funcs))

##### test infrastructures #####
tinytest::setup_tinytest(pkgdir = my_tempdir, verbose = FALSE)
# Remove placeholder
unlink(fs::path(my_tempdir, "inst", "tinytest", paste0("test_", pkg_name, ".R")))

# Notes:
# - Using 'usethis::use_test(name = testthat_funcs[1L], open = FALSE)' or
#   'usethis::use_testthat()', possibly wrapped in 'usethis::ui_silence()' as
#   shortcut instead of the code below does NOT work inside
#   'tinytest::test_all()': then testthat infrastructure is added to
#   'develcoder' instead of to the temporary directory.
fs::dir_create(path = fs::path(my_tempdir, "tests", "testthat"))
testfile_testthat <- fs::path(fs::dir_create(fs::path(my_tempdir, "tests")),
                              "testthat.R")
fs::file_create(testfile_testthat)
expect_true(fs::is_file(testfile_testthat))
writeLines(text = c("library(testthat)", paste0("library(", pkg_name, ")"),
                    paste0("test_check(\"", pkg_name, "\")")),
           con = testfile_testthat)
desc <- desc::desc_set_dep(
  package = "testthat", type = "Suggests", file = path_desc)


##### test files #####
fs::file_create(
  fs::path(path_tinytest, paste0(c("test_", "test-"), tinytest_funcs)))
fs::file_create(
  fs::path(path_testthat, paste0(c("test_", "test-"), testthat_funcs)))

#### Tests ####

##### all is fine #####
expect_silent(
  expect_identical(
    check_tests(path = my_tempdir),
    character(0)
  )
)

##### testfiles and ignored files (1) #####
# The ignored files do not have corresponding function files in 'R'
ignored_general <- c("abctest-.R", "test-def.txt", "test_ghi.txt", "jkl.txt",
                     "test-func", "test-func.Rd")
ignored_tinytest <- "ignored_tinytest.R"
ignored_testthat <- "ignored_testthat.R"
path_ignored_tinytest <- fs::file_create(
  fs::path(path_tinytest, c(ignored_tinytest, ignored_general)))
path_ignored_testthat <- fs::file_create(
  fs::path(path_testthat, c(ignored_testthat, ignored_general)))
expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = paste0(
    pattern_ignored, "'tinytest' or\nhave names.+\\^test_\\|\\^test-.+\n",
    progutils::paste_quoted(
      # Select only the first and last item to prevent tests failing because of
      # differences in the sorting order of '-' and '_'.
      sort(c(ignored_tinytest, progutils::head_tail(ignored_general, n = 1L))),
      collapse = "\n.*")),
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = paste0(
    pattern_ignored, "'testthat' or\nhave names.+\\^test_\\|\\^test-.+\n",
    progutils::paste_quoted(
      # Select only the first and last item to prevent tests failing because of
      # differences in the sorting order of '-' and '_'.
      sort(c(ignored_testthat, progutils::head_tail(ignored_general, n = 1L))),
      collapse = "\n.*")),
  strict = TRUE)

unlink(c(fs::path(path_testthat, ignored_general),
         fs::path(path_tinytest, ignored_general)))

##### testfiles and ignored files (2) #####
# The ignored files have corresponding function files in 'R'
path_ignored_R_tinytest <- fs::file_create(fs::path(path_R, ignored_tinytest))
path_ignored_R_testthat <- fs::file_create(fs::path(path_R, ignored_testthat))

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    c(ignored_testthat, ignored_tinytest)
  ),
  pattern = paste0(
    pattern_ignored, "'tinytest' or\nhave names.+\\^test_\\|\\^test-.+\n",
    progutils::paste_quoted(ignored_tinytest, collapse = "\n")),
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    c(ignored_testthat, ignored_tinytest)
  ),
  pattern = paste0(
    pattern_ignored, "'testthat' or\nhave names.+\\^test_\\|\\^test-.+\n",
    progutils::paste_quoted(ignored_testthat, collapse = "\n")),
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    c(ignored_testthat, ignored_tinytest)
  ),
  pattern = paste0(pattern_no_test_file,
                   progutils::paste_quoted(c(ignored_testthat, ignored_tinytest),
                                           collapse = "\n")),
  strict = TRUE)

##### some function files missing #####
unlink(
  c(path_ignored_tinytest, path_ignored_testthat,
    path_ignored_R_tinytest, path_ignored_R_testthat,
    path_other_funcs))

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    other_funcs
  ),
  pattern = paste0("No function file found corresponding to test file ",
                   progutils::paste_quoted(other_funcs, collapse = "\n")),
  strict = TRUE)

# Re-create function files
fs::file_create(path_other_funcs)

##### non-function files in R #####
path_misc <- fs::file_create(fs::path(path_R, "misc_file.txt"))

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  ),
  pattern = paste0("Ignoring non-R files in folder '", path_R,
                   "':\n'misc_file.txt'"),
  strict = TRUE)
unlink(path_misc)

##### misc #####
# testdir missing; testdir empty; testdir non-empty but without testfiles;
# testdir with testfiles and ignored files that not have func files;
# testdir with only testfiles: checked in file 'test_diagnose_test_files.R'

##### All files fine but infra wrong #####
tinytest::setup_tinytest(pkgdir = my_tempdir, verbose = FALSE)
# Remove placeholder
unlink(fs::path(my_tempdir, "inst", "tinytest", paste0("test_", pkg_name, ".R")))

expect_silent(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    character(0)
  )
)

fs::file_create(fs::path(my_tempdir, "R", "file2.R"))
fs::file_create(fs::path(my_tempdir, "tests", "testthat", "test-file3.R"))

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    c("file2.R", "file3.R")
  ), pattern = "No test file found corresponding to function file 'file2.R'",
  strict = TRUE, fixed = TRUE
)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    c("file2.R", "file3.R")
  ), pattern = "No function file found corresponding to test file 'file3.R'",
  strict = TRUE, fixed = TRUE
)

expect_silent(
  expect_identical(
    diagnose_test_infra(path = fs::path(my_tempdir, "inst", "tinytest")),
    list(name = "tinytest", status = "missing", dependency = "fine")
  )
)

expect_silent(
  expect_identical(
    diagnose_test_files(path = fs::path(my_tempdir, "inst", "tinytest")),
    list(pattern = "^test_|^test-", ignore_case = TRUE,
         status_testdir = "present", status_test_files = "fine",
         test_files = c("test-other_func_tinytest.R", "test_some_func_tinytest.R"),
         ignored_files = character(0))
  )
)

# Set up testthat infrastructure
# NB. Using `usethis::use_testthat()` does not work: that does NOT create the
# correct files in the tempdir but in the current project (i.e., develcoder)
testfile_testthat <- fs::path(fs::dir_create(fs::path(my_tempdir, "tests")),
                              "testthat.R")
fs::file_create(testfile_testthat)
expect_true(fs::is_file(testfile_testthat))
writeLines(text = c("library(testthat)", paste0("library(", pkg_name, ")"),
                    paste0("test_check(\"", pkg_name, "\")")),
           con = testfile_testthat)

# TO DO:
# - Should warn about 'testthat' template file?
expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    c("file2.R", "file3.R")
  ),
  pattern = "No test file found corresponding to function file 'file2.R'",
  strict = TRUE, fixed = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    c("file2.R", "file3.R")
  ),
  pattern = "No function file found corresponding to test file 'file3.R'",
  strict = TRUE, fixed = TRUE)

# Remove tinytest test infrastructure
unlink(fs::path(my_tempdir, "tests", "tinytest.R"))
expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    c("file2.R", "file3.R", "other_func_tinytest.R", "some_func_tinytest.R")
  ),
  pattern = "No test file found corresponding to function file 'file2.R'",
  strict = TRUE, fixed = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    c("file2.R", "file3.R", "other_func_tinytest.R", "some_func_tinytest.R")
  ),
  pattern = "No function file found corresponding to test file 'file3.R'",
  strict = TRUE, fixed = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test_|^test-"),
    c("file2.R", "file3.R", "other_func_tinytest.R", "some_func_tinytest.R")
  ),
  pattern = paste0("Test files will be ignored because test infrastructure for",
                   " tinytest is missing\nor does not refer to the current package",
                   " .run 'tinytest::setup_tinytest.)' to\ncreate the test",
                   " infrastructure.:\n'test-other_func_tinytest.R'\n'test_some_func_tinytest.R'"),
  strict = TRUE)

expect_silent(
  expect_identical(
    diagnose_test_infra(path = fs::path(my_tempdir, "inst", "tinytest")),
    list(name = "tinytest", status = "missing", dependency = "fine")
  )
)

expect_silent(
  expect_identical(
    diagnose_test_infra(path = fs::path(my_tempdir, "tests", "testthat.R")),
    list(name = "testthat", status = "fine", dependency = "fine")
  )
)

##### testthat template files in <pkg>\tests\testthat

##### tinytest template files in <pkg>\inst\tinytest

##### testfiles duplicated in tinytest/testthat

##### testfiles that only differ in case from each other #####

##### func files that only differ in case from each other #####

##### R dir empty #####

##### R dir missing #####

#### Fine ####

##### 'pattern' is respected #####
old_func <- c("file2.R", "file3.R", "other_func_tinytest.R")
some_func <- c("some_func_testthat.R", "some_func_tinytest.R")
expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test-"),
    c(old_func, some_func)
  ),
  pattern = paste0(
    pattern_ignored,
    "'tinytest' or\nhave names.+\\^test-.+\n'test_some_func_tinytest.R'"),
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test-"),
    c(old_func, some_func)
  ),
  pattern = paste0(
    pattern_ignored,
    "'testthat' or\nhave names.+\\^test-.+\n'test_some_func_testthat.R'"),
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^test-"),
    c(old_func, some_func)
  ),
  pattern = paste0(
    pattern_no_test_file,
    progutils::paste_quoted(c(old_func[-2], some_func), collapse = "\n")),
  strict = TRUE)

expect_warning(
  expect_identical(
    diagnose_test_files(path = path_tinytest, pattern = "^test-"),
    list(pattern = "^test-", ignore_case = TRUE,
         status_testdir = "present", status_test_files = "wrong",
         test_files = "test-other_func_tinytest.R",
         ignored_files = "test_some_func_tinytest.R")
  ),
  pattern = paste0(
    pattern_ignored,
    "'tinytest' or\nhave names.+\\^test-.+\n'test_some_func_tinytest.R'"),
  strict = TRUE)

expect_warning(
  expect_identical(
    diagnose_test_files(path = path_testthat, pattern = "^test-"),
    list(pattern = "^test-", ignore_case = TRUE,
         status_testdir = "present", status_test_files = "wrong",
         test_files = c("test-file3.R", "test-other_func_testthat.R"),
         ignored_files = "test_some_func_testthat.R")
  ),
  pattern = paste0(
    pattern_ignored,
    "'testthat' or\nhave names.+\\^test-.+\n'test_some_func_testthat.R'"),
  strict = TRUE)

##### 'ignore_case' is respected #####
unlink(c(fs::path(path_tinytest, "test-other_func_tinytest.R"),
         fs::path(path_testthat, "test-other_func_testthat.R"),
         fs::path(path_R, "file2.R"), fs::path(path_R, "other_func_tinytest.R")))
fs::file_create(fs::path(path_tinytest, "TEst-other_func_tinytest.R"))
fs::file_create(fs::path(path_testthat, "TEst-other_func_testthat.R"))

expect_warning(
  expect_identical(
    check_tests(
      path = my_tempdir, pattern = "^TEst_|^TEst-", ignore_case = TRUE),
    c("file3.R", "some_func_tinytest.R"),
  ), pattern = paste0("Test files will be ignored because test infrastructure",
                      " for tinytest is missing")
)

expect_silent(
  expect_identical(
    diagnose_test_files(
      path = path_tinytest, pattern = "^TEst_|^TEst-", ignore_case = TRUE),
    list(pattern = "^TEst_|^TEst-", ignore_case = TRUE,
         status_testdir = "present", status_test_files = "fine",
         test_files = c("TEst-other_func_tinytest.R", "test_some_func_tinytest.R"),
         ignored_files = character(0))
  )
)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^TEst_|^TEst-",
                ignore_case = FALSE),
    some_func
  ),
  pattern = paste0(
    pattern_ignored,
    "'tinytest' or\nhave names.+\\^TEst_\\|\\^TEst-.+\n'test_some_func_tinytest.R'"),
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^TEst_|^TEst-", ignore_case = FALSE),
    some_func
  ),
  pattern = paste0(
    pattern_ignored,
    "'testthat' or\nhave names.+\\^TEst_\\|\\^TEst-.+\n'test_some_func_testthat.R'"),
  strict = TRUE)

expect_warning(
  expect_identical(
    check_tests(path = my_tempdir, pattern = "^TEst_|^TEst-", ignore_case = FALSE),
    some_func
  ),
  pattern = paste0(pattern_no_test_file,
                   progutils::paste_quoted(some_func, collapse = "\n")),
  strict = TRUE)

expect_warning(
  expect_identical(
    diagnose_test_files(path = path_tinytest, pattern = "^TEst_|^TEst-",
                        ignore_case = FALSE),
    list(pattern = "^TEst_|^TEst-", ignore_case = FALSE,
         status_testdir = "present", status_test_files = "wrong",
         test_files = "TEst-other_func_tinytest.R",
         ignored_files = "test_some_func_tinytest.R")),
  pattern = paste0(
    pattern_ignored,
    "'tinytest' or\nhave names.+\\^TEst_\\|\\^TEst-.+\n'test_some_func_tinytest.R'"),
  strict = TRUE)

# Re-create original test files
unlink(c(fs::path(path_tinytest, "TEst-other_func_tinytest.R"),
         fs::path(path_testthat, "TEst-other_func_testthat.R")))
fs::file_create(fs::path(path_tinytest, "test-other_func_tinytest.R"))
fs::file_create(fs::path(path_testthat, "test-other_func_testthat.R"))

##### Arguments that should result in an error #####
expect_warning(
  expect_error(
    check_tests(path = 3),
    pattern = error_not_path, fixed = TRUE),
  pattern = error_path, strict = TRUE, fixed = TRUE)

expect_warning(
  expect_error(
    diagnose_test_files(path = 3),
    pattern = error_not_path, fixed = TRUE),
  pattern = error_path, strict = TRUE, fixed = TRUE)

expect_warning(
  expect_error(
    diagnose_test_infra(path = 3),
    pattern = error_not_path, fixed = TRUE),
  pattern = error_path, strict = TRUE, fixed = TRUE)

expect_warning(
  expect_error(
    check_tests(path = "c"),
    pattern = error_not_path, fixed = TRUE),
  pattern = error_path_sep, strict = TRUE, fixed = TRUE)

expect_warning(
  expect_error(
    diagnose_test_files(path = "c"),
    pattern = error_not_path, fixed = TRUE),
  pattern = error_path_sep, strict = TRUE, fixed = TRUE)

expect_warning(
  expect_error(
    diagnose_test_infra(path = "c"),
    pattern = error_not_path, fixed = TRUE),
  pattern = error_path_sep, strict = TRUE, fixed = TRUE)

expect_error(
  check_tests(path = my_tempdir, ignore_case = NA),
  pattern = "is_logical(ignore_case) is not TRUE", fixed = TRUE)

expect_error(
  diagnose_test_files(path = path_tinytest, ignore_case = NA),
  pattern = "is_logical(ignore_case) is not TRUE", fixed = TRUE)


#### Remove objects used in tests ####
unlink(my_tempdir, recursive = TRUE)
rm(desc, error_not_path, ignored_general, ignored_testthat, ignored_tinytest,
   my_tempdir,
   other_funcs, path_desc, path_ignored_R_testthat, path_ignored_R_tinytest,
   path_ignored_testthat, path_ignored_tinytest, path_misc, path_other_funcs,
   path_R, path_testthat, path_tinytest, pattern_desc, pattern_ignored,
   pattern_no_test_file, pkg_name, some_func, testfile_testthat, test_funcs,
   testthat_funcs, tinytest_funcs, error_path, error_path_sep)
