# Diagnose test files

Get test files, with an overview of various diagnostics

## Usage

``` r
diagnose_test_files(
  path = fs::path_wd("inst", "tinytest"),
  pattern = "^test_|^test-",
  ignore_case = TRUE
)
```

## Arguments

- path:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing a [valid
  path](https://jessealderliesten.github.io/checkinput/reference/is_path.html)
  to the directory where to look for tests.

- pattern:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing a [regular expression](https://rdrr.io/r/base/regex.html)
  used to select test files.

- ignore_case:

  `TRUE` or `FALSE`: ignore case when matching filenames to `pattern`?

## Value

A [list](https://rdrr.io/r/base/list.html) with six elements:

- `pattern`: the value of argument `pattern`

- `ignore_case`: the value of argument `ignore_case`

- `status_testdir`: character string: `"fine"` if the test directory
  indicated by `path` is present, otherwise `"missing"`

- `status_test_files`: character string indicating the status of the
  test files: `"fine"` if test files are present; `"wrong"` if files are
  ignored; `"missing"` if no test files are present

- `test_files`: character vector with the names of test files.
  `character(0)` if no test files are present.

- `ignored_files`: character vector with the names of files in `path`
  that are **not** test files. `character(0)` if no files are ignored.

## Details

The default `path` points to directory `inst/tinytest` of the current
[working directory](https://rdrr.io/r/base/getwd.html), where
[`tinytest`](https://CRAN.R-project.org/package=tinytest) stores tests
when a package is in development.

A warning is issued if:

- `path` contains files that are ignored because their names do **not**
  start with pattern `pattern`, are not R files, or are template files
  created by [`tinytest`](https://CRAN.R-project.org/package=tinytest)

`diagnose_test_files()` does **not** warn about other problems detected
with the test files: that is deferred to
[`check_tests()`](https://jessealderliesten.github.io/develcoder/reference/check_tests.md).

## See also

Other functions to check tests:
[`check_tests()`](https://jessealderliesten.github.io/develcoder/reference/check_tests.md),
[`diagnose_test_infra()`](https://jessealderliesten.github.io/develcoder/reference/diagnose_test_infra.md)

## Examples

``` r
path_develcoder <- find.package("develcoder")
# test files are present
diagnose_test_files(path = fs::path(path_develcoder, "inst", "tinytest"))
#> $pattern
#> [1] "^test_|^test-"
#> 
#> $ignore_case
#> [1] TRUE
#> 
#> $status_testdir
#> [1] "missing"
#> 
#> $status_test_files
#> [1] "missing"
#> 
#> $test_files
#> character(0)
#> 
#> $ignored_files
#> character(0)
#> 

# test directory is missing
diagnose_test_files(path = fs::path(path_develcoder, "inst", "othertest"))
#> $pattern
#> [1] "^test_|^test-"
#> 
#> $ignore_case
#> [1] TRUE
#> 
#> $status_testdir
#> [1] "missing"
#> 
#> $status_test_files
#> [1] "missing"
#> 
#> $test_files
#> character(0)
#> 
#> $ignored_files
#> character(0)
#> 

# empty test directory
tempdir_example <- progutils::create_tempdir(prefix = "diagnose_test_files")
withr::with_dir(new = tempdir_example, {
  # Set up a package with testing infrastructure from tinytest
  desc <- desc::description$new("!new")
  desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
  desc::desc_set(Package = "somepkg")

  fs::dir_create(fs::path(tempdir_example, "inst", "tinytest"))
  diagnose_test_files(path = fs::path(tempdir_example, "inst", "tinytest"))
})
#> $pattern
#> [1] "^test_|^test-"
#> 
#> $ignore_case
#> [1] TRUE
#> 
#> $status_testdir
#> [1] "present"
#> 
#> $status_test_files
#> [1] "missing"
#> 
#> $test_files
#> character(0)
#> 
#> $ignored_files
#> character(0)
#> 
```
