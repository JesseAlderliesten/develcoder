# Match package name

Match a package name to the content of files.

## Usage

``` r
match_pkg_name(
  pkg_name,
  pkg_dir = ".",
  file_patterns = c("\\NEWS", "\\README", "\\_pkgdown"),
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

- file_patterns:

  [character
  vector](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing regular expressions to match to file names in `pkg_dir`,
  using case-insensitive matching. Can be `character(0)` to not check
  any files. Hidden files (i.e., files with names starting with a dot)
  are **not** found.

- warn_files_absent:

  `TRUE` or `FALSE`: [warn](https://rdrr.io/r/base/warning.html) if
  files matching `file_patterns` are absent from `pkg_dir`, or if
  `citation_fields` is not `character(0)` and the
  [CITATION](https://docs.ropensci.org/cffr/reference/cff_read.html)
  file is absent from `pkg_dir`. Missing files are silently ignored if
  `warn_files_absent` is `FALSE`.

## Value

The paths to the files that were checked, returned
[invisibly](https://rdrr.io/r/base/invisible.html).

## See also

[`pkg_name_correct()`](https://jessealderliesten.github.io/develcoder/reference/pkg_name_correct.md),
[`usethis::use_news_md()`](https://usethis.r-lib.org/reference/use_news_md.html),
[`usethis::use_pkgdown()`](https://usethis.r-lib.org/reference/use_pkgdown.html)

## Examples

``` r
match_pkg_name(pkg_name = "develcoder", warn_files_absent = FALSE)
match_pkg_name(pkg_name = "develcoder", warn_files_absent = TRUE)
#> Warning: No files found matching pattern '\NEWS'
#> Warning: No files found matching pattern '\README'
#> Warning: No files found matching pattern '\_pkgdown'
```
