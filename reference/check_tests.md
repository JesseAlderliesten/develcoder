# Check tests

Check if testing infrastructure is present and refers to the current
package, and if function files have a corresponding test file and vice
versa.

## Usage

``` r
check_tests(path = getwd(), pattern = "^test_|^test-", ignore_case = TRUE)
```

## Arguments

- path:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing a valid
  [path](https://jessealderliesten.github.io/checkinput/reference/is_path.html)
  to the package of which to check testing infrastructure and test
  files. The default is the [working
  directory](https://rdrr.io/r/base/getwd.html).

- pattern:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing a [regular expression](https://rdrr.io/r/base/regex.html)
  used to select test files.

- ignore_case:

  `TRUE` or `FALSE`: ignore case when matching filenames to `pattern`?

## Value

If all function files in folder `R` have a corresponding used test file
and vice versa (which also is the case if no test files and no function
files are present): `character(0)`. Otherwise, a character vector with
the names of test files for which no function file is present and
function files for which no used test file is present.

## Details

This function looks for R files starting with pattern `pattern` in
folders `inst/tinytest` and `tests/testthat` in the directory indicated
by `path`, which is where
[`tinytest`](https://CRAN.R-project.org/package=tinytest) and
[`testthat`](https://CRAN.R-project.org/package=testthat) place their
test files, respectively.

It is checked that testing infrastructure is present and refers to the
current package, and that all test files have corresponding function
files and vice versa. Test files are ignored if the corresponding test
infrastructure is missing or wrong, with a warning. Function files of
re-exported functions are ignored when looking for corresponding test
files because these functions should be tested in the package from which
they are re-exported.

Warnings are issued if:

- none of the test directories
  [exist](https://fs.r-lib.org/reference/file_access.html)

- none of the test directories contain test files

- test directories contain files that are ignored because their names do
  **not** start with pattern `pattern`, are not R files, or are template
  files created by
  [`tinytest`](https://CRAN.R-project.org/package=tinytest) or
  [`testthat`](https://testthat.r-lib.org/)

- test directories used by `tinytest` or `testthat` contain test files
  while their test architecture is not set up

- test directories contain test files without corresponding function
  files in folder `R`

- folder `R` contains function files without corresponding test files

- folder `R` contains files that are not R files

- folder `R` does not contain any function files

- files `<pkg>\tests\tinytest.R` or `<pkg>\tests\testthat.R` determining
  which test infrastructure is used are present but do **not** refer to
  the current package, or the packages `tinytest` and `testthat` are
  missing from the dependencies of the tested package

- file `<pkg>\tests\tinytest.R` nor `<pkg>\tests\testthat.R` is present

- file `reexports.Rd` is present in folder `man` but no re-exported
  functions are present in folder `R`

## See also

Other functions to check tests:
[`diagnose_test_files()`](https://jessealderliesten.github.io/develcoder/reference/diagnose_test_files.md),
[`diagnose_test_infra()`](https://jessealderliesten.github.io/develcoder/reference/diagnose_test_infra.md)

## Examples

``` r
path_develcoder <- find.package("develcoder")
# test files are present
check_tests(path = path_develcoder) # character(0)
#> Warning: No file determining the used testing infrastructure exists:
#> '/home/runner/work/_temp/Library/develcoder/tests/tinytest.R',
#> '/home/runner/work/_temp/Library/develcoder/tests/testthat.R'
#> Warning: None of the test directories exist:
#> '/home/runner/work/_temp/Library/develcoder/inst/tinytest'
#> '/home/runner/work/_temp/Library/develcoder/tests/testthat'
#> Warning: Ignoring non-R files in folder '/home/runner/work/_temp/Library/develcoder/R':
#> 'develcoder'
#> 'develcoder.rdb'
#> 'develcoder.rdx'
#> Warning: No function files found.
#> character(0)

# warnings: test infrastructure, directories, and function files not present
tempdir_example <- progutils::create_tempdir(prefix = "check_tests")
withr::with_dir(new = tempdir_example, {
  # Set up a package without testing infrastructure
  desc <- desc::description$new("!new")
  desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
  check_tests(path = tempdir_example)
})
#> Warning: No file determining the used testing infrastructure exists:
#> '/tmp/RtmpMZ702x/check_tests1a7f4ae2abcf/tests/tinytest.R',
#> '/tmp/RtmpMZ702x/check_tests1a7f4ae2abcf/tests/testthat.R'
#> Warning: None of the test directories exist:
#> '/tmp/RtmpMZ702x/check_tests1a7f4ae2abcf/inst/tinytest'
#> '/tmp/RtmpMZ702x/check_tests1a7f4ae2abcf/tests/testthat'
#> Warning: No function files found.
#> character(0)
# Remove temporary directory
unlink(tempdir_example, recursive = TRUE)
```
