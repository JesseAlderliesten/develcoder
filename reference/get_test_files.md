# Get test files

Get test files, emitting a signal if test files do not have
corresponding function files or vice versa.

## Usage

``` r
get_test_files(
  testdir,
  pattern = "^test_|^test-",
  ignore_case = TRUE,
  signal = c("error", "warning", "message", "quiet")
)
```

## Arguments

- testdir:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing a [valid
  path](https://jessealderliesten.github.io/checkinput/reference/is_path.html)
  to the directory containing tests.

- pattern:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing a [regular expression](https://rdrr.io/r/base/regex.html)
  used to select test files.

- ignore_case:

  `TRUE` or `FALSE`: ignore case when matching filenames to `pattern`?

- signal:

  Character string indicating the type of signal to be used: `"error"`
  to throw an [error](https://rdrr.io/r/base/stop.html), `"warning"` to
  issue a [warning](https://rdrr.io/r/base/warning.html), `"message"` to
  show a [message](https://rdrr.io/r/base/message.html), or `"quiet"` to
  be quiet.

## Value

A character vector containing the found test files, which is
`character(0)` if no test files are found, with
[attribute](https://rdrr.io/r/base/attributes.html) `"info"` containing
a character string with the text of the
[signal](https://jessealderliesten.github.io/progutils/reference/signal_text.html),
which is `""` if no signal was emitted.

## Details

The
[signal](https://jessealderliesten.github.io/progutils/reference/signal_text.html)
indicated by argument `signal` is emitted if directory `testdir`:

- does not [exist](https://fs.r-lib.org/reference/file_access.html)

- contains files that are ignored because they do not start with pattern
  `pattern`, are not R files, or are template files created by
  `tinytest`

- contain test files without corresponding function files in folder `R`

- does not contain any test files

A character string with the text of this signal is also present as
attribute `"info"` of the returned value.

## See also

[`check_test_files()`](https://jessealderliesten.github.io/develcoder/reference/check_test_files.md)
that uses this function and checks some more
