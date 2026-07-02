# Check if test infrastructure is present and refers to the current package

Check if test infrastructure is present and refers to the current
package

## Usage

``` r
check_test_infra(
  path_infra = fs::path_wd("tests", "tinytest.R"),
  signal = c("error", "warning", "message", "quiet")
)
```

## Arguments

- path_infra:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  with a path to the file which determines the test infrastructure, see
  `Details`.

- signal:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  indicating the type of signal to be used: `"error"` to throw an
  [error](https://rdrr.io/r/base/stop.html), `"warning"` to issue a
  [warning](https://rdrr.io/r/base/warning.html), `"message"` to show a
  [message](https://rdrr.io/r/base/message.html), or `"quiet"` to be
  quiet.

## Value

A character vector containing a character string with the text of the
[signal](https://jessealderliesten.github.io/progutils/reference/signal_text.html),
which is `""` if no signal is emitted.

## Details

The default `path_infra` points to file `tinytest.R` in directory
`tests` of the current [working
directory](https://rdrr.io/r/base/getwd.html), which belongs to the test
infrastructure of
[`tinytest`](https://CRAN.R-project.org/package=tinytest). To use the
test infrastructure of
[`testthat`](https://CRAN.R-project.org/package=testthat), use
`path_infra = fs::path_wd("tests", "testthat.R")`.

The
[signal](https://jessealderliesten.github.io/progutils/reference/signal_text.html)
indicated by argument `signal` is emitted:

- if the package indicated in `path_infra` is not among the dependencies

- if the file that determines the used testing infrastructure does not
  exist

- if the file that determines the used testing infrastructure does not
  refer to the package in the current working directory
