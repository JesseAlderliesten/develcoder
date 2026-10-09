##### Create temporary directory #####
# Create a temporary directory and temporarily set the working directory to it
my_tempdir <- progutils::create_tempdir(prefix = "check_tests")
pkg_name <- basename(my_tempdir)
withr::local_dir(new = my_tempdir)

##### No files present #####
expect_silent(
  expect_identical(
    match_pkg_name(pkg_name = "develcoder", pkg_dir = my_tempdir,
                   file_patterns = "NOTNEWS", warn_files_absent = FALSE),
    character(0))
)

expect_warning(
  expect_identical(
    match_pkg_name(pkg_name = "develcoder", pkg_dir = my_tempdir,
                   file_patterns = "NOTNEWS", warn_files_absent = TRUE),
    character(0)), pattern = "No files found matching pattern 'NOTNEWS'"
)

expect_silent(
  expect_identical(
    match_pkg_name(pkg_name = "develcoder", pkg_dir = my_tempdir,
                   file_patterns = "devel", warn_files_absent = FALSE),
    character(0))
)

expect_warning(
  expect_identical(
    match_pkg_name(pkg_name = "develcoder", pkg_dir = my_tempdir,
                   file_patterns = "devel", warn_files_absent = TRUE),
    character(0)), pattern = "No files found matching pattern 'devel'"
)

#### NEWS ####
path_news <- fs::path(my_tempdir, "NEWS")
fs::file_create(path_news)
expect_true(fs::is_file(path_news))

expect_error(
  match_pkg_name(pkg_name = "develcoder", pkg_dir = my_tempdir,
                 file_patterns = "NEWS"),
  pattern = "The package name 'develcoder' is missing from file.+NEWS'$")

# file_patterns are regular expressions that are matched case-insensitively
expect_error(
  match_pkg_name(pkg_name = "develcoder", pkg_dir = my_tempdir,
                 file_patterns = ".ew"),
  pattern = "The package name 'develcoder' is missing from file.+NEWS'$")

writeLines(text = c("some text on a line", "text with develcoder on next line"),
           con = path_news)
expect_true(
  endsWith(x = match_pkg_name(pkg_name = "develcoder", pkg_dir = my_tempdir,
                              file_patterns = "news"),
           suffix = "NEWS")
)

# file_patterns are regular expressions that are matched case-insensitively
expect_true(
  endsWith(x = match_pkg_name(pkg_name = "develcoder", pkg_dir = my_tempdir,
                              file_patterns = ".ew"),
           suffix = "NEWS")
)

# Matching package name is case-sensitive
expect_error(
  match_pkg_name(pkg_name = "DEVELcoder", pkg_dir = my_tempdir,
                 file_patterns = "NEWS"),
  pattern = "The package name 'DEVELcoder' is missing from file.+NEWS'$")

##### Arguments that should result in an error #####
expect_error(match_pkg_name(),
             pattern = "argument \"pkg_name\" is missing", fixed = TRUE)
expect_error(match_pkg_name(pkg_name = 3),
             pattern = "checkinput::is_character(pkg_name) is not TRUE", fixed = TRUE)
expect_warning(
  expect_error(match_pkg_name(pkg_name = "develcoder", pkg_dir = 3),
               pattern = "checkinput::is_path(pkg_dir) is not TRUE", fixed = TRUE),
  pattern = "'pkg_dir' should be a non-empty, non-NA_character_ character string")
expect_error(match_pkg_name(pkg_name = "develcoder", file_patterns = 3),
             pattern = paste0("checkinput::all_characters(file_patterns,",
                              " allow_zerolength = TRUE) is not TRUE"), fixed = TRUE)
expect_error(match_pkg_name(pkg_name = "develcoder", warn_files_absent = 1),
             pattern = "checkinput::is_logical(warn_files_absent) is not TRUE",
             fixed = TRUE)
expect_error(match_pkg_name(pkg_name = "develcoder", warn_files_absent = NA),
             pattern = "checkinput::is_logical(warn_files_absent) is not TRUE",
             fixed = TRUE)

#### Cleaning up ####
unlink(my_tempdir, recursive = TRUE)
rm(my_tempdir, path_news, pkg_name)
