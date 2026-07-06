# Diagnose test infrastructure

Check if test infrastructure is present and refers to the current
package.

## Usage

``` r
diagnose_test_infra(path = fs::path_wd("tests", "tinytest.R"))
```

## Arguments

- path:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing a [valid
  path](https://jessealderliesten.github.io/checkinput/reference/is_path.html)
  where to look for the file that determines the test infrastructure.

## Value

A [list](https://rdrr.io/r/base/list.html) with three elements:

- `name`: character string containing the name of the test
  infrastructure that is looked for

- `status`: character string indicating the status of the test
  infrastructure: `"fine"` if it is present and refers to package `pkg`;
  `"wrong"` if it is present but does **not** refer to package `pkg`;
  `"missing"` if it is **not** present

- `dependency`: character string: `"fine"` if the package belonging to
  the testing infrastructure (i.e., `name`) is present among the
  dependencies of package `pkg`, otherwise `"missing"`

## Details

The default `path` points to file `tinytest.R` in directory `tests` of
the current [working directory](https://rdrr.io/r/base/getwd.html), to
check the test infrastructure of
[`tinytest`](https://CRAN.R-project.org/package=tinytest). Use
`path = fs::path_wd("tests", "testthat.R")` to check the test
infrastructure of
[`testthat`](https://CRAN.R-project.org/package=testthat).

A warning is issued if a file determining the used testing
infrastructure (e.g., `<pkg>\tests\tinytest.R` or
`<pkg>\tests\testthat.R`) exists but:

- it does **not** refer to the tested package

- the package that governs the determined testing infrastructure (e.g.,
  `tinytest` or `testthat`) is missing from the dependencies of the
  tested package

`diagnose_test_infra()` does **not** warn about problems detected with
the test infrastructure: that is deferred to
[`check_tests()`](https://jessealderliesten.github.io/develcoder/reference/check_tests.md).

## See also

Other functions to check tests:
[`check_tests()`](https://jessealderliesten.github.io/develcoder/reference/check_tests.md),
[`diagnose_test_files()`](https://jessealderliesten.github.io/develcoder/reference/diagnose_test_files.md)

## Examples

``` r
path_develcoder <- find.package("develcoder")
# test infrastructure is present
diagnose_test_infra(path = fs::path(path_develcoder, "tests", "tinytest.R"))
#> $name
#> [1] "tinytest"
#> 
#> $status
#> [1] "missing"
#> 
#> $dependency
#> [1] "fine"
#> 

# test infrastructure is not present
tempdir_example <- progutils::create_tempdir(prefix = "diagnose_test_infra")
withr::with_dir(new = tempdir_example, {
  # Set up a package without testing infrastructure
  desc <- desc::description$new("!new")
  desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
  diagnose_test_infra(path = fs::path(tempdir_example, "tests", "tinytest.R"))
})
#> $name
#> [1] "tinytest"
#> 
#> $status
#> [1] "missing"
#> 
#> $dependency
#> [1] "missing"
#> 
```
