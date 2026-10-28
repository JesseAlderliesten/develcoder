# Check Tests

Check if testing infrastructure is present and refers to the current
package, and if function files have a corresponding test file and vice
versa.

## Usage

``` r
check_tests(
  path = getwd(),
  pattern = "^test_|^test-",
  ignore_case = TRUE,
  test_vignettes = FALSE
)
```

## Arguments

- path:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing a valid
  [path](https://jessealderliesten.github.io/checkinput/reference/is_path.html)
  to the folder with the package of which the testing infrastructure and
  test files should be checked. The default is the [working
  directory](https://rdrr.io/r/base/getwd.html).

- pattern:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing a [regular expression](https://rdrr.io/r/base/regex.html)
  used to select test files.

- ignore_case:

  `TRUE` or `FALSE`: ignore case when matching filenames to `pattern`?

- test_vignettes:

  `TRUE` or `FALSE`: should vignettes have a corresponding test file?

## Value

If all is fine: `character(0)`. Otherwise, a list containing components
`missing` and `extraneous` containing character vectors with the names
of function files for which no used test file is present, and the names
of test files for which no function file is present, respectively.

## Details

This function looks for R files starting with pattern `pattern` in
folders `inst/tinytest` and `tests/testthat` in the directory indicated
by `path`, which is where
[**tinytest**](https://CRAN.R-project.org/package=tinytest) and
[**testthat**](https://CRAN.R-project.org/package=testthat) place their
test files, respectively.

It is checked that testing infrastructure referring to the current
package is present. Test files are ignored if the corresponding test
infrastructure is missing or wrong, with a warning.

It is checked that all test files have a corresponding `.R` function
file in folder `R` or an `.Rmd` vignette in folder `vignettes`. It is
also checked that all function files and, if `test_vignettes` is `TRUE`,
all vignettes, have a corresponding test file. Function files of
re-exported functions are ignored when looking for corresponding test
files because those functions should be tested in the package from which
they are re-exported.

Warnings are issued if:

- none of the test directories
  [exist](https://fs.r-lib.org/reference/file_access.html)

- none of the test directories contain test files

- test directories contain files that are ignored because their names do
  **not** start with pattern `pattern`, are not R files, or are template
  files created by
  [**tinytest**](https://CRAN.R-project.org/package=tinytest) or
  [**testthat**](https://testthat.r-lib.org/)

- test directories used by **tinytest** or **testthat** contain test
  files while their test architecture is not set up

- test directories contain test files without corresponding function
  file in folder `R` or vignette in folder `vignettes`

- folder `R` contains function files without corresponding test files

- folder `R` contains files that are not R files

- folder `R` does not contain any function files

- folder `vignettes` contains files that are not `.Rmd` files

- folder `vignettes` contains `.Rmd` files without corresponding test
  files while `test_vignettes` is `TRUE`

- files `tests\tinytest.R` or `tests\testthat.R` determining which test
  infrastructure is used are present but do **not** refer to the current
  package, or the packages **tinytest** and **testthat** are missing
  from the dependencies of the tested package

- file `tests\tinytest.R` nor `tests\testthat.R` is present

- file `man\reexports.Rd` is present but no re-exported functions are
  present in folder `R`

## See also

Section [Set up testing
infrastructure](https://jessealderliesten.github.io/develcoder/articles/pkg_setup.html#set-up-testing-infrastructure)
in vignette *Package setup* and section [Add
tests](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html#add-tests)
in vignette *Package development*:
[`vignette("pkg_setup", package = "develcoder")`](https://jessealderliesten.github.io/develcoder/articles/pkg_setup.md)
and
[`vignette("pkg_devel", package = "develcoder")`](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.md).

Other functions to check tests: `check_tests()`,
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
#> 'develcoder',
#> 'develcoder.rdb',
#> 'develcoder.rdx'
#> Warning: No function files found in folder '/home/runner/work/_temp/Library/develcoder/R'.
#> $missing
#> character(0)
#> 
#> $extraneous
#> character(0)
#> 

if(requireNamespace("withr", quietly = TRUE)) {
# warnings: test infrastructure, directories,
# and function files not present
tempdir_example <- progutils::create_tempdir(
  prefix = "check_tests")
withr::with_dir(new = tempdir_example, {
  # Set up a package without testing infrastructure
  desc <- desc::description$new("!new")
  desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
  check_tests(path = tempdir_example)
})
# Remove temporary directory
unlink(tempdir_example, recursive = TRUE)
}
#> Warning: No file determining the used testing infrastructure exists:
#> '/tmp/RtmpO631bu/check_tests1d4e1f4fe972/tests/tinytest.R',
#> '/tmp/RtmpO631bu/check_tests1d4e1f4fe972/tests/testthat.R'
#> Warning: None of the test directories exist:
#> '/tmp/RtmpO631bu/check_tests1d4e1f4fe972/inst/tinytest'
#> '/tmp/RtmpO631bu/check_tests1d4e1f4fe972/tests/testthat'
#> Warning: No function files found in folder '/tmp/RtmpO631bu/check_tests1d4e1f4fe972/R'.
```
