# Check for the presence of test files

Check if all function files have a corresponding test file and vice
versa.

## Usage

``` r
check_test_files(
  path_pkg = getwd(),
  pattern = "^test_|^test-",
  ignore_case = TRUE
)
```

## Arguments

- path_pkg:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing a valid
  [path](https://jessealderliesten.github.io/checkinput/reference/is_path.html)
  to the package to be checked. The default is the [working
  directory](https://rdrr.io/r/base/getwd.html).

- pattern:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing a [regular expression](https://rdrr.io/r/base/regex.html)
  used to select test files.

- ignore_case:

  `TRUE` or `FALSE`: ignore case when matching filenames to `pattern`?

## Value

If all R files have a corresponding test file: `character(0)`.
Otherwise, a character vector with the names of R files for which no
test file was found.

## Details

This function looks for R files starting with pattern `pattern` in
folders `inst/tinytest`, `tinytest`, and `tests/testthat` in the
directory indicated by `path_pkg`, where
[`tinytest`](https://CRAN.R-project.org/package=tinytest) and
[`testthat`](https://CRAN.R-project.org/package=testthat) place their
test files, respectively.

It is checked that all test files have corresponding function files and
vice versa. Function files of re-exported functions are ignored when
looking for corresponding test files because these functions should be
tested in the package from which they are re-exported.

Warnings are issued if:

- none of the test directories exist

- none of the test directories contain any test files

- the test directories contain files that are ignored because their
  names do not start with pattern `pattern`, are not R files, or are
  template files created by
  [`tinytest`](https://CRAN.R-project.org/package=tinytest)

- the test directories contain test files without corresponding function
  files in folder `R`

- folder `R` contains function files without corresponding test files

- file `<pkg>\tests\tinytest.R` is present but its code does not contain
  the name of the current package

- a `reexports.Rd` file is present in folder `man` but no re-exported
  functions are found in folder `R`

## See also

[`get_test_files()`](https://jessealderliesten.github.io/develcoder/reference/get_test_files.md)
that is used by this function
