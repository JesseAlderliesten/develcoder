# Check consistent use of package name

Check that the correct package name is used in various files in the
package directory.

## Usage

``` r
pkg_name_correct(
  pkg_name,
  pkg_dir = ".",
  description_fields = c("Package", "URL", "BugReports"),
  citation_fields = c("title", "repository-code", "url"),
  file_patterns = c("\\NEWS", "\\README", "\\_pkgdown"),
  warn_fields_absent = FALSE,
  warn_files_absent = FALSE
)
```

## Arguments

- pkg_name:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html):
  the package name that should be present in the checked fields and
  files.

- pkg_dir:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html):
  the
  [path](https://jessealderliesten.github.io/checkinput/reference/is_path.html)
  to the directory where to look for files. Subdirectories are **not**
  checked.

- description_fields, citation_fields:

  [character
  vectors](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  naming the fields of the
  [DESCRIPTION](https://desc.r-lib.org/reference/description.html) and
  [CITATION](https://docs.ropensci.org/cffr/reference/cff_read.html)
  files to check. Use `character(0)` to not check any fields.

- file_patterns:

  [character
  vector](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing regular expressions to match to file names in `pkg_dir`,
  using case-insensitive matching. Can be `character(0)` to not check
  any files. Hidden files (i.e., files with names starting with a dot)
  are **not** found.

- warn_fields_absent:

  `TRUE` or `FALSE`: [warn](https://rdrr.io/r/base/warning.html) if
  fields indicated by `description_fields` and `citation_fields` are
  absent from the
  [DESCRIPTION](https://desc.r-lib.org/reference/description.html) and
  [CITATION](https://docs.ropensci.org/cffr/reference/cff_read.html)
  file in `pkg_dir`. Missing fields are silently ignored if
  `warn_fields_absent` is `FALSE`.

- warn_files_absent:

  `TRUE` or `FALSE`: [warn](https://rdrr.io/r/base/warning.html) if
  files matching `file_patterns` are absent from `pkg_dir`, or if
  `citation_fields` is not `character(0)` and the
  [CITATION](https://docs.ropensci.org/cffr/reference/cff_read.html)
  file is absent from `pkg_dir`. Missing files are silently ignored if
  `warn_files_absent` is `FALSE`.

## Value

The paths to files that were present and thus checked, returned
[invisibly](https://rdrr.io/r/base/invisible.html).

## Details

An error is thrown if any of the checked fields or files is present but
does not contain the package name `pkg_name`.

A single
[DESCRIPTION](https://desc.r-lib.org/reference/description.html) file
should be present in `pkg_dir` and it should have a `Package` field
containing the package name `pkg_name`, otherwise an error is thrown.

`file_patterns` start with `\\` instead of `^` because the latter does
not work with the used
[`fs::dir_ls()`](https://fs.r-lib.org/reference/dir_ls.html) if
`pkg_dir` is not `"."`.

## See also

[`match_pkg_name()`](https://jessealderliesten.github.io/develcoder/reference/match_pkg_name.md),
[`desc::description()`](https://desc.r-lib.org/reference/description.html),
[`cffr::cff_read_citation()`](https://docs.ropensci.org/cffr/reference/cff_read.html),
[`usethis::use_news_md()`](https://usethis.r-lib.org/reference/use_news_md.html),
[`usethis::use_pkgdown()`](https://usethis.r-lib.org/reference/use_pkgdown.html)

## Examples

``` r
if(requireNamespace("withr", quietly = TRUE)) {
# Create a temporary directory and temporarily set the working directory to it
my_tempdir <- progutils::create_tempdir(prefix = "ex_pkg_name_correct")
pkg_name <- basename(my_tempdir)
withr::local_dir(new = my_tempdir)

# Add a DESCRIPTION file
desc <- desc::description$new("!new")
path_desc <- fs::path(my_tempdir, "DESCRIPTION")
desc$set("Package", "toypackage")
desc$set("URL", "https://github.com/JesseAlderliesten/toypackage")
desc$set("BugReports", "https://github.com/JesseAlderliesten/toypackage/issues")
desc$write(file = path_desc)

pkg_name_correct(pkg_name = "toypackage", pkg_dir = my_tempdir,
                 description_fields = "Package", file_patterns = "DESC")
# Error because field 'URL' in 'DESCRIPTION' does not give the package name
try(pkg_name_correct(pkg_name = "toypackage", pkg_dir = my_tempdir,
                     description_fields = c("Package", "URL"),
                     file_patterns = "DESC"))

# Warn no 'NEWS' file is found if 'warn_files_absent' is 'TRUE'
pkg_name_correct(pkg_name = "toypackage", pkg_dir = my_tempdir,
                 description_fields = "Package",
                 citation_fields = character(0), file_patterns = "NEWS",
                 warn_files_absent = TRUE)
pkg_name_correct(pkg_name = "toypackage", pkg_dir = my_tempdir,
                 description_fields = "Package",
                 citation_fields = character(0), file_patterns = "NEWS",
                 warn_files_absent = FALSE)

# Error because field 'Package' in 'DESCRIPTION' gives other package name
try(pkg_name_correct(pkg_name = "not_toypackage", pkg_dir = my_tempdir,
                     description_fields = "Package"))

# Warn about missing field, not checking other files because 'file_patterns'
# is 'character(0)'
pkg_name_correct(pkg_name = "toypackage", pkg_dir = my_tempdir,
                 description_fields = "not_title",
                 file_patterns = character(0), warn_fields_absent = TRUE)

# return to normal working directory
withr::deferred_run()
}
#> Warning: No files found matching pattern 'NEWS'
#> Error in .check_field_pkg_name(pkg_name = pkg_name, file_path = desc_path,  : 
#>   The package name 'not_toypackage' is missing from field 'Package' of file
#> '/tmp/RtmpuZ4Pyb/ex_pkg_name_correct199b67ae730e/DESCRIPTION' which is:
#> toypackage
#> Warning: Field 'not_title' is missing from file
#> '/tmp/RtmpuZ4Pyb/ex_pkg_name_correct199b67ae730e/DESCRIPTION'
#> Ran 1/1 deferred expressions
```
