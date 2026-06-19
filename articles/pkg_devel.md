# Package development

## Introduction

This vignette contains code and annotations to develop a package, to
prepare for package release, and to set up for a new version. It assumes
the package has been set up as described in the vignette *Package
setup*:
[`vignette("pkg_setup", package = "develcoder")`](https://jessealderliesten.github.io/develcoder/articles/pkg_setup.md).

## Adding functions

### Set up

``` r
usethis::use_r("<func>")
devtools::document() # also runs devtools::load_all()
?<func>() # view help-page of the function
```

Do:

- Manually update the `NEWS` file:  
  `` - Add `<func>()` to ... ``.
- If the added function relies on other packages, you have to update the
  dependencies given in the `DESCRIPTION` file: see section [Update
  dependencies](#update-dependencies).
- When adding new function arguments to an existing function, it is best
  practice to place the new argument after existing arguments and use a
  default value that matches the old behaviour: then code written for
  the old version will work the same as before the change, even if it
  relies on positional matching, such that it is a **non**-breaking
  change.
- When renaming functions, remember to also change their names in the
  `_pkgdown.yml` file if that file is used to create a custom index for
  the website
  ([`pkgdown::build_reference()`](https://pkgdown.r-lib.org/reference/build_reference.html)
  warns about it if you forget).

### Documentation

``` r
#' Title
#'
#' Description
#'
#' @param x Vector of names to test.
#' @param allow_NA `TRUE` or `FALSE`: allow [NA]s of the correct type in `x`?
#' @param x,y Separate arguments by a comma without a space to create a single
#' description for multiple arguments.
#'
#' @details
#'
#' @returns
#' `TRUE` or `FALSE`, returned [invisibly][invisible].
#'
#' @section Side effects:
#' The directory indicated by the returned path is
#' [created][progutils::create_dir()] if it does not yet exist.
#'
#' @section Notes:
#' Some notes.
#'
#' @section Programming notes:
#' Some programming notes. Create a GitHub issue instead of To do / Wishlist
#' sections.
#'
#' @seealso
#' Section `Details` of [make.names()] and the [\R FAQ about valid names](
#' https://CRAN.R-project.org/doc/manuals/R-FAQ.html#What-are-valid-names_003f)
#' on the syntactical validity of names.
#'
#' @family collections of checks on type and length
#'
#' @examples
#' all_names(x = c("a", "b2a")) # TRUE
#'
#' @export
func_name <- function(x, allow_NA = TRUE) {
  stopifnot(checkinput::is_logical(allow_NA))
  <...>
}
```

#### Inherit documentation and parameters

It is possible to inherit sections of the documentation from other
functions. Inherited sections are **silently** ignored if that section
is also defined in the file itself.

``` r

#' @inherit is_number return
#' @inherit is_number details
#' @inheritSection is_logical Programming notes
#' @inheritSection is_logical @note
```

#### Inherit parameters

It is possible to inherit the description of parameters from other
functions. Since `roxygen2` 8.0.0, it is possible to specify which
arguments to inherit.

``` r
# inherit from a function in the current package
@inheritParams is_logical allow_NA

# inherit from a function in another package
@inheritParams utils::installed.packages fields
```

#### Add examples

Examples should **not** write to the working directory (e.g., using
[`getwd()`](https://rdrr.io/r/base/getwd.html)) but to a temporary
directory that is cleaned up afterwards. See the section
`Usage in practice` in
[`help("create_tempdir", package = "progutils")`](https://jessealderliesten.github.io/progutils/reference/create_tempdir.html).

Although examples rendered on a website created with
[`pkgdown`](https://pkgdown.r-lib.org/) will display the output
underneath the code, help-files accessed through `help(<func>)` will
not, such that it might be useful to include a short comment regarding
what feature of the output is notable.

To run all examples in a package:

``` r

devtools::run_examples()
```

To not run or not display code in examples, you can use the `dontrun`
and `dontshow` tags, see the section
[`Examples`](https://cran.r-project.org/doc/manuals/R-exts.html#Documenting-functions)
from the
[`Writing R Extensions manual`](https://cran.r-project.org/doc/manuals/R-exts.html)
and the section about
[`Examples`](https://r-pkgs.org/man.html#sec-man-examples-errors) in the
book `R packages`.

#### Styling

Newlines can be forced using `\cr`.

For an overview of mathematical notation see:
<https://rpruim.github.io/s341/S19/from-class/MathinRmd.html>

### Add tests

Tests should write to a temporary directory that is cleaned up
afterwards. See the section `Usage in practice` in
[`help("create_tempdir", package = "progutils")`](https://jessealderliesten.github.io/progutils/reference/create_tempdir.html).
More generally, tests should not make changes (without restoring the
original state) that could influence subsequent tests. Examples of such
changes are any options and changes to the state of the global
environment (see the vignette
[`test fixtures`](https://testthat.r-lib.org/articles/test-fixtures.html)
from package `testthat` for more details).

Note that `expect_silent(...)` tests that no errors or warnings are
emitted, **not** that no messages are emitted.

``` r

tinytest::expect_silent(expect_true(func_name(x = x, arg = arg)))
tinytest::expect_warning(
  expect_equal(func_name(x = "a", arg = arg), 3),
  pattern = "...", strict = TRUE, fixed = TRUE)
tinytest::expect_error(func_name(x = "a", arg = arg),
             pattern = "is_number(x) is not TRUE", fixed = TRUE)
```

The code below shows how to run tests.

``` r

# Run all tests of a package. Use 'devtools::test()' instead of
# 'tinytest::test_all()' if you used package 'testthat' to create tests.
tinytest::test_all()

# Run a specific test file, selecting the file by name
tinytest::run_test_file(fs::path(getwd(), "inst", "tinytest", "test_funcname.R"))
# Run specific test files, selecting the files by order
tinytest::run_test_file(
  list.files(fs::path(getwd(), "inst", "tinytest"), full.names = TRUE)[1:3])
```

#### Testing file paths

Testing file paths requires some thought because the file separator
depends on the operating system (see `.Platform$file.sep`) and the
backward slash is used as escape character in `R` such that it needs to
be escaped itself by doubling them. Thus, a check on the presence of
successive slashes and backslashes in string `string` would use
`grepl(pattern = "//", x = string, fixed = TRUE)` and
`grepl(pattern = "\\\\", x = string, fixed = TRUE)`. The message to
point out their presence would be written as
`message("Successive '/' or '\\\\'")` which would be printed as
`Successive '/' or '\\'`.

To circumvent the hassle of getting the correct type and number of
slashes to compare with the path recorded in a message, check only for
fixed parts of the message (e.g., `"Repeated"`), possibly followed by a
check like `tinytest::expect_true(fs::dir_exists(string))`.

### Update dependencies

#### Importing packages or functions

The standard way to use functions from other packages is to import the
package (i.e., put it in the `Imports:` field of the `DESCRIPTION` file;
this is done by  
`usethis::use_package("<pkg>", type = "Imports", min_version = "<version>")`)
and in code use the package name followed by two colons and the function
name, e.g.,
[`utils::osVersion()`](https://rdrr.io/r/utils/sessionInfo.html).

Using two colons to specify the package is not possible if the function
is an operator: then it is necessary to also list the function in the
`NAMESPACE` file, e.g., to add the line  
`#' @importFrom utils osVersion` to the file `R/<pkg>-package.R` that
was created by
[`usethis::use_package_doc()`](https://usethis.r-lib.org/reference/use_package_doc.html).
This is done by
`usethis::use_import_from(package = "utils", fun = "osVersion")`.

``` r

usethis::use_import_from(package = "utils", fun = "osVersion")
usethis::use_package("utils", type = "Suggests", min_version = "4.1.0")
```

#### Specifying minimum versions

Specifying a minimum package version when importing packages ensures
that used features are actually present. Setting `min_version = TRUE` in
[`usethis::use_package()`](https://usethis.r-lib.org/reference/use_package.html)
uses the currently installed package version but that might be too
strict as features are likely also present in older versions.

To check in which version used features were introduced, you can search
the `NEWS` file of the relevant package for the function name to find
the news item announcing its introduction. If that does not work, you
can search for the function R file on the GitHub-page of the package and
look in its history to see when it was created (or use the `Blame`
feature to get a fine-grained overview of when code in that file was
changed to see when a feature was introduced). Finally, you can also
specify different minimum package versions in checks through GitHub
actions and iteratively change them to find the minimum version that
passes the check. Then specify that version as minimum version in your
`DESCRIPTION` file.

Since `R` 4.6.0, [`read.dcf()`](https://rdrr.io/r/base/dcf.html)
recognises lines starting with `#` as comment lines, making it possible
to use comments in the `DESCRIPTION` file to indicate why a particular
package version is needed.

``` r

# Declare a minimum version for R itself
usethis::use_package("R", type = "Depends", min_version = "4.1.0")

# Declare a dependency on a package: 'use_package()' to declare a minimum
# version and 'use_dev_package()' to specify the remote repository to download
# the package from.
usethis::use_package(package = "checkinput", type = "Imports", min_version = TRUE)
usethis::use_dev_package(package = "checkinput", type = "Imports",
                         remote = "github::JesseAlderliesten/checkinput")
usethis::use_package(package = "progutils", type = "Imports", min_version = TRUE)
usethis::use_dev_package(package = "progutils", type = "Imports",
                         remote = "github::JesseAlderliesten/progutils")
devtools::document()
```

Do:

- Specify the minimum declared `R` version as workflow in GitHub
  Actions, see the section [Use GitHub Actions](#use-github-actions).

## Adding vignettes

### Set up

``` r

usethis::use_vignette("my_vignette", title = "Some title")
# Add suggested dependencies on 'knitr' and 'rmarkdown'
usethis::use_package(package = "knitr", type = "Suggests")
usethis::use_package(package = "rmarkdown", type = "Suggests")
devtools::document()
pkgdown::build_article()
browseVignettes(package = basename(getwd()))
```

If no vignettes are visible after running
`browseVignettes(package = basename(getwd()))`,
[`devtools::install()`](https://devtools.r-lib.org/reference/install.html)
was probably run with the default argument `build_vignettes = FALSE`,
use `build_vignettes = TRUE` instead:
`devtools::install(quick = FALSE, upgrade = FALSE, build_vignettes = TRUE)`.
Run `tools::pkgVignettes(package = "<pkg>")` for information about the
vignettes that R finds.

Use `utils::vignette("<vignette_title>")` (e.g.,
[`utils::vignette("pkg_devel")`](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.md))
and `tools::Rd2txt("path/to/file.Rd")` to render a vignette or an `Rd`
file in the `help` pane of RStudio, respectively.

### Styling

See the vignette *RMarkdown and knitr*:
[`vignette("rmarkdown_knitr", package = "develcoder")`](https://jessealderliesten.github.io/develcoder/articles/rmarkdown_knitr.md))
on using RMarkdown to style vignettes.

Put the next lines in the header of vignettes to get a table of
contents:

``` r

output:
  rmarkdown::html_vignette:
  toc: true
toc_depth: 3
```

### Linking

- Link to another section in the same document:  
  `[<Section title>]` or `[<link text>][<Section title>]`.
- Link to a help page of a package:  
  `help("<func>", package = "<pkg>")` (unfortunately,
  `help("<pkg>::<func>")` does **not** work).
- Link from a help-page to a vignette:  
  `` The vignette *<vignette title>*: `vignette("<vignette>", package = "<pkg>")` ``
- Link to another vignette in the same package:  
  `[<link text>](<vignette_filename>.html)`

There are [**no**](https://r-pkgs.org/vignettes.html#links) official
ways to link from vignettes to help-pages or vice versa. `pkgdown`
recognises calls like `` `<func>()` `` and `` `<pkg>::<func>()` ``, such
that relevant links for such calls will be created on a package website
(see the
[documentation](https://pkgdown.r-lib.org/articles/linking.html) for
details).

## Adding miscellaneous files

Non-standard files or folders should be added in the `inst/` directory
to pass [`R CMD checks`](https://r-pkgs.org/R-CMD-check.html). Those
files and folders will be in the top directory in the installed package.

## Preparing for updates

### Check tests

Check if there are functions for which no test file was written and run
all test files. Use
[`devtools::test()`](https://devtools.r-lib.org/reference/test.html)
instead of
[`tinytest::test_all()`](https://rdrr.io/pkg/tinytest/man/run_test_dir.html)
if you used package [testthat](https://testthat.r-lib.org/) to create
tests.

``` r

devtools::document()
tinytest::test_all() # or devtools::test()
curr_pkg_name <- basename(getwd())
files_R <- list.files(file.path(".", "R"))
files_man <- list.files(path = file.path(".", "man"), pattern = "\\.Rd$")
proj_pkg_R <- paste0(curr_pkg_name, "-package.R")
if(proj_pkg_R %in% files_R) {
  files_R <- files_R[files_R != proj_pkg_R]
  files_man <- files_man[files_man != paste0(proj_pkg_R, "d")]
}
if("reexports.Rd" %in% files_man) {
  files_man <- files_man[files_man != "reexports.Rd"]
  # Based on https://stackoverflow.com/a/74487073/32365738
  reexported_funcs <- progutils::not_in(getNamespaceExports(curr_pkg_name),
                                        ls(envir = asNamespace(curr_pkg_name)))
  if(length(reexported_funcs) == 0L) {
    warning("File 'reexports.Rd' is present but no re-exported functions found!")
  } else {
    files_R <- progutils::not_in(files_R, paste0(reexported_funcs, ".R"))
  }
}
expected_man <- sub(pattern = "\\.Rd$", replacement = ".R", x = files_man)
expected_files <- sort(unique(paste0("test_", c(files_R, expected_man))))
tests_missing <- expected_files[!(expected_files %in% list.files("./inst/tinytest"))]
if(length(tests_missing) > 0L) {
  warning("No test file found for file ", progutils::paste_quoted(tests_missing))
}
```

### Automated checks

[`tools::CRAN_check_results()`](https://rdrr.io/r/tools/CRANtools.html),
[`tools::CRAN_check_details()`](https://rdrr.io/r/tools/CRANtools.html)
and
[`tools::CRAN_check_issues()`](https://rdrr.io/r/tools/CRANtools.html)
give information about the current check status of CRAN packages.
[cransays](https://r-hub.github.io/cransays/index.html) (source code
[here](https://github.com/r-hub/cransays)) provides information about
the status of packages during package submission to CRAN.

The next sections provide code to run checks from various packages.

#### devtools (local)

The default
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
from [devtools](https://CRAN.R-project.org/package=devtools) should be
run often.
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
uses the preferred approach of first building the package before
checking it, whereas
[rcmdcheck::rcmdcheck()](https://rcmdcheck.r-lib.org/reference/rcmdcheck.html)
does not but is able to compare output from different checks.

See the [CRAN
cookbook](https://contributor.r-project.org/cran-cookbook/) and the
appendix [`R-CMD-check`](https://r-pkgs.org/R-CMD-check.html) from the
book ‘R packages’ on how to proceed if checks fail.

The call to
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
used here is more strict than the default, following suggestions from
the [Writing R extensions
manual](https://cran.r-project.org/doc/manuals/r-release/R-exts.html#Suggested-packages)
and from [R
packages](https://r-pkgs.org/release.html#double-r-cmd-checking) (see
the [manual](https://cran.r-project.org/doc/manuals/r-devel/R-ints.html)
for details about the environment variables):

- Using `manual = TRUE` to build and check the manual.

- Using `remote = TRUE` (and thus `incoming = TRUE`) to run additional
  checks that are used by CRAN for new package submissions.

  These checks identify problems with linked URLs (i.e., not with URLs
  in comments). URLs:

  - should be accessible (e.g., point to public GitHub repositories, not
    to private repositories)
  - should be direct links, not redirects
  - should use the protocol `http://` instead of `https://`
  - should use the canonical forms expected by CRAN, not the ‘simple’
    form displayed in the webbrowser:
    - `https://CRAN.R-project.org/package=<pkg>` for packages
    - `https://CRAN.R-project.org/manuals.html` to refer to manuals [in
      general](https://CRAN.R-project.org/manuals.html) and URLs of the
      form
      `https://CRAN.R-project.org/doc/manuals/r-release/R-exts.html` to’
      refer to a [specific
      manual](https://CRAN.R-project.org/doc/manuals/r-release/R-exts.html)
    - `https://CRAN.R-project.org/web/packages/policies.html` to refer
      to the [CRAN
      policies](https://CRAN.R-project.org/web/packages/policies.html).

  These checks also flag dependencies that are on GitHub, leading to
  NOTEs like  
  `Strong dependencies not in the CRAN or BioC software repositories: <pkg>`,  
  `Suggests or Enhances not in mainstream repositories: <pkg>`, and  
  `Unknown, possibly misspelled, fields in DESCRIPTION: 'Remotes'`.  
  If you do **not** intend to submit to CRAN, you can ignore these
  NOTEs.

- Using `TRUE` for environment variable `_R_CHECK_DEPENDS_ONLY_` to run
  code while only using dependencies listed in the `Depends` and
  `Imports` fields of the `DESCRIPTION` file. This catches cases where a
  package that is listed in the `Suggests` field of the `DESCRIPTION`
  file is used in a vignette without being run conditionally through
  `if(requireNamespace(<pkg>)) {<code>}`.

- Using `TRUE` for environment variable `_R_CHECK_SUGGESTS_ONLY_` to run
  code while only using dependencies listed in the `Depends`, `Imports`
  and `Suggests` fields of the `DESCRIPTION` file.

- If you get the warning:
  `Warning in get_engine(options$engine): Unknown language engine '<name>' (must be registered via knit_engines$set())`,
  you probably forgot to indicate the knit-engine when naming a code
  chunk:

      ```{use-sum}
      1 + 1
      ```

  erroneously tries to use the engine `use-sum`, whereas the probably
  intended `{r use-sum}` correctly indicates that the `r` engine should
  be used and the code chunk should be named `use-sum`:

      ```{r use-sum}
      1 + 1
      ```

  See `sort(names(knitr::knit_engines$get()))` for the available
  knit-engines.

- If you get the error
  `Failed with error: 'there is no package called '<pkg>''`
  `Quitting from <filename>.Rmd:<line numbers> [<chunk name>]`, you
  probably forgot to use `library(<pkg>)` in a code chunck, used a
  package that is not declared as dependency in the `DESCRIPTION` file,
  or used a package that is declared as suggested dependency (i.e., is
  in the `Suggests` field of the `DESCRIPTION` file) without running
  that code conditionally on the presence of `<pkg>` through
  `if(requireNamespace(<pkg>)) {<code>}`. The latter is catched by
  running `env_vars = c("_R_CHECK_DEPENDS_ONLY_" = TRUE)`.

- If checks fail because of `LaTeX` errors when building the manual, you
  can use `manual = FALSE`.

``` r

devtools::document()
devtools::check(manual = TRUE, remote = TRUE)
devtools::check(manual = TRUE, remote = TRUE,
                env_vars = c("_R_CHECK_DEPENDS_ONLY_" = TRUE,
                             "_R_CHECK_SUGGESTS_ONLY_" = TRUE))
devtools::release_checks()
if(utils::packageVersion("devtools") >= "2.5.0") {
  # check for missing `\value` and `\examples` fields in `Rd` files
  devtools::check_doc_fields()
}
```

#### devtools (remote)

The following checks might be used to check the package on Windows or
MacOS, respectively.
[`devtools::check_win_release()`](https://devtools.r-lib.org/reference/check_win.html)
emails a link to a webpage with the check results if the check is done.
[`devtools::check_mac_release()`](https://devtools.r-lib.org/reference/check_mac_release.html)
links to a webpage where the results are shown if the check is done (the
webpage might display ‘504 Gateway Time-out’ if it has not finished
yet).

These checks might malfunction if your package has dependencies that are
not on CRAN or BioConductor. These dependencies should have been flagged
above by `devtools::check(manual = TRUE, remote = TRUE)` as
`not in the CRAN or BioC software repositories` or as
`not in mainstream repositories`).

``` r

devtools::check_win_release()
devtools::check_mac_release()
```

#### codetools

Check R code for possible problems.

``` r

devtools::load_all()
codetools::checkUsagePackage(pack = basename(getwd()),
                             all = TRUE, suppressParamAssigns = TRUE)
```

#### utils

Spell checking. This requires system libraries like
[Aspell](http://aspell.net/).

``` r

utils::aspell_package_Rd_files(dir = getwd())
utils::aspell_package_vignettes(dir = getwd())
```

#### goodpractice

Runs checks of its own and checks from various other packages.

I do not use
[pkgcheck::pkgcheck()](https://docs.ropensci.org/pkgcheck/reference/pkgcheck.html)
because their [‘own’
checks](https://docs.ropensci.org/pkgcheck/articles/list-checks.html)
are largely covered by the checks from `devtools` used
\[above\]\[devtool\], their checks from `goodpractice` are already
covered here, and the checks from
[pkgstats](https://docs.ropensci.org/pkgstats/reference/pkgstats.html)
are not interesting and require system libraries `ctags-universal` and
`GNU global`. However, the `pkgcheck` [GitHub
action](https://github.com/ropensci-review-tools/pkgcheck-action) (see
also [here](https://github.com/r-universe-org/workflows)) might be
useful.

``` r

# Select checks
# Show groups of checks: goodpractice::all_check_groups()
# Show all checks in some groups: goodpractice::checks_by_group(c("cyclocomp", "lintr"))
# Run all check from some groups:
# goodpractice::goodpractice(checks = goodpractice::checks_by_group(c("cyclocomp", "lintr")))
goodpractice_all_checks <- goodpractice::all_checks()
my_checks_goodpractice <- progutils::not_in(
  goodpractice_all_checks,
  c("covr", # time-consuming according to 'pkgcheck'
    "complexity_function_length", "cyclocomp", # I write complex functions
    # The lintr issue `Use == instead of %in% for scalar comparison` should be
    # ignored for 'x %in% y' if 'x' or 'y' might contain 'NA' that should be
    # removed: 'x %in% NA' and 'NA %in% y' return 'FALSE', whereas 'x == NA' and
    # 'NA == y' return 'NA'.
    "lintr_scalar_in_linter",
    "lintr_line_length_linter",
    "lintr_outer_negation_linter", # changes handling of NAs
    # flags data.frame() even if 'strings_as_factors' is not explicitly set
    "lintr_strings_as_factors_linter",
    "tidyverse_brace_linter",
    "tidyverse_function_left_parentheses_linter",
    "tidyverse_indentation_linter",
    "tidyverse_line_length_linter",
    "tidyverse_object_name_linter",
    "tidyverse_spaces_left_parentheses_linter",
    # does not find test-files in inst/tinytest, use check_test_files() instead.
    "tidyverse_test_file_names",
    "tidyverse_whitespace_linter",
    
    # Checks similar to those from 'rcmdcheck' and 'urlchecker' are also used by
    # devtools::check() that already has been run above
    goodpractice_all_checks[
      grepl(pattern = "^rcmdcheck_|^urlchecker_", x = goodpractice_all_checks)]
  )
)

res_goodpractice <- goodpractice::gp(path = ".", checks = my_checks_goodpractice)
res_goodpractice_failed <- goodpractice::failed_checks(res_goodpractice)
res_goodpractice_failed

# Can also show output of selected checks through
# res_goodpractice$checks$<check_name>
res_goodpractice
```

#### See also

- usethis::use_release_issue()
- <https://bioconductor.org/packages/release/bioc/html/BiocCheck.html>
- <https://github.com/hturner/pkg-dev-ctv/blob/main/proposal.md#checking-a-package>

### Locally test update

``` r

devtools::document()
.libPaths() # Check if output of .libPaths() is correct.
devtools::install(quick = FALSE, upgrade = FALSE, build_vignettes = TRUE)

# Load the package and view the help files as usual outside devtools:
library(basename(getwd()), character.only = TRUE)
browseVignettes(package = basename(getwd()))
?progutils::reorder_levels
```

### Check reverse dependencies

**Acknowledgement** This section reproduces a
[contribution](https://stat.ethz.ch/pipermail/r-package-devel/2026q2/012397.html)
by Ivan Krylov to the [R-pkg-devel mailing
list](https://stat.ethz.ch/mailman/listinfo/r-package-devel) of 26 May
2026.

To check if packages that use your package still pass their checks if
you made breaking changes, install the new version of your package, run
`tools::package_dependencies(reverse = TRUE, which = "most", recursive = "strong")`
to get the list of reverse dependencies, then use
`utils::download.packages(...)` to obtain their latest tarballs and
finally run
[`tools::check_packages_in_dir()`](https://rdrr.io/r/tools/check_packages_in_dir.html)
to check them. See also
[`xfun::rev_check()`](https://rdrr.io/pkg/xfun/man/rev_check.html),
package [crandalf](https://github.com/yihui/crandalf), and package
[revdepcheck](https://revdepcheck.r-lib.org/).

### Update package-wide documentation

- `README`: after adjusting the `README.Rmd`, `Knit` it to produce a
  `README.Md` file. You can follow the `usethis` practice of using
  [`devtools::build_readme()`](https://devtools.r-lib.org/reference/build_readme.html)
  to update `README.md`, which requires that `README.Rmd` and
  `README.md` are staged at the same time. To remove this requirement,
  delete the the (hidden) file `.git/hooks/pre-commit` from the
  R-project folder (see the `Description` section in
  [`help("use_readme_rmd", package = "usethis")`](https://usethis.r-lib.org/reference/use_readme_rmd.html)).
- `NEWS`: restyle and publish the `NEWS` file at each new package
  release.
- `DESCRIPTION`: run
  [`desc::desc_normalize()`](https://desc.r-lib.org/reference/desc_normalize.html)
  to normalize the `DESCRIPTION` file. Manually increment the package
  version in the `DESCRIPTION` file, or run `R` as administrator and
  then use
  [`usethis::use_version()`](https://usethis.r-lib.org/reference/use_version.html).
  In the latter case, do **not** automatically `commit` the change, but
  do so manually to adjust the commit message to
  `Bump to version x.y.z`. Indicating the version number in the commit
  title makes it easier to find changes back later on (the pull request
  can have a description of the changes, i.e., the updated section of
  the `NEWS` file).
- `CITATION.cff`: update your citation file to reflect the new package
  version (this code uses the citation file if it exists and otherwise
  uses the the `DESCRIPTION` file):

``` r

cffr::cff_write(dependencies = FALSE) # Create or update a citation file
```

## Updating

### Use GitHub Actions

To manually run GitHub Actions (GHA) set up `workflow_dispatch` (see
section `Automate checks` in the vignette *Package setup*:
[`vignette("pkg_setup", package = "develcoder")`](https://jessealderliesten.github.io/develcoder/articles/pkg_setup.md)).

To check if a reverse dependency (i.e., a package that depends on a
package you changed) is still working fine: go to the `Actions` tab of
the reverse dependency, select the action you want to trigger (e.g.,
`R-CMD-check.yaml`), and use the `Run workflow` button to run the GHA.
You can select which branch it should run on, but you need to trigger it
once manually on the `main` branch to be able to trigger it manually on
other branches.

Scheduled jobs that failed can be rerun through the button `Re-run jobs`
\> `Re-run failed jobs` \> `Re-run jobs`. If the GitHub actions page
(e.g., <https://github.com/JesseAlderliesten/develcoder/actions>)
indicates the package passes the
[`R CMD checks`](https://r-pkgs.org/R-CMD-check.html) whereas the badge
on the `README` indicates it fails, make sure the `R CMD check`
considers the `main` branch (i.e., if the `devel` branch passes but the
`main` branch fails, the badge will have `failing`): use the
`Run workflow` button to run the GHA on the `main` branch (see the
previous paragraph).

If the package declares a dependency on a minimum `R` version, it is
useful to specify the minimum declared `R` version to run in addition to
the ones that are by default used in the template:  
add `- {os: ubuntu-latest, r: '4.1.0'}` to section `matrix: config:` to
run `R` 4.1.0.

### pkgdown website

See the documentation about package
[`pkgdown`](https://pkgdown.r-lib.org/) and the
[`chapter`](https://r-pkgs.org/website.html) from the `R packages` book.

``` r

# To manually update the website
pkgdown::build_site()
```

Open `docs/index.html` in a web browser to preview the website, or look
at the files that constitute your package’s website are in the local
`docs/` directory.

Instead of manually updating the pkgdown website, one can use a [GitHub
Action](#use-github-actions) workflow (e.g.,
[`pkgdown.yaml`](https://github.com/JesseAlderliesten/develcoder/blob/main/.github/workflows/pkgdown.yaml))
that updates the website after a pull request or push. To set this up,
run
[`usethis::use_pkgdown_github_pages()`](https://usethis.r-lib.org/reference/use_pkgdown.html).

#### Styling

To create a thematic index instead of the default alphabetically ordered
one, see the
[documentation](https://pkgdown.r-lib.org/reference/build_reference.html)
and the
[example](https://github.com/r-lib/pkgdown/blob/main/pkgdown/_pkgdown.yml).

To customise the order in which `Articles` are listed, specify their
order in the `_pkgdown.yml` file (run
`tools::pkgVignettes(package = "<pkg>")$names` to get their names; see
the
[documentation](https://pkgdown.r-lib.org/reference/build_articles.html)
and for example the `_pkgdown.yml`
[file](https://github.com/JesseAlderliesten/checkrpkgs/blob/master/.github/workflows/pkgdown.yaml)
and non-alphabetical order of the
[articles](https://jessealderliesten.github.io/checkrpkgs/articles/) in
the `checkrpkgs` package.

To create a custom function index, include a section `reference:` in the
`_pkgdown.yml` file with the desired headings and topics, see the
[documentation](https://pkgdown.r-lib.org/reference/build_reference.html),
an [official
example](https://github.com/r-lib/pkgdown/blob/main/pkgdown/_pkgdown.yml)
and [my own
example](https://github.com/JesseAlderliesten/progutils/blob/main/_pkgdown.yml).
Then build the reference with
[`pkgdown::build_reference()`](https://pkgdown.r-lib.org/reference/build_reference.html)
and view it locally by opening the file `"<pkg>\docs\index.html"` and
browse to `Reference` to see the package index.

### Merge devel-branch with master

To merge the `devel` branch with `master`, go the the `devel` branch on
GitHub. `<Contribute>` \> `Open Pull Request`. Copy the updated `NEWS`
in the `description` field and use the button `Create pull request`.

If the message
`No conflicts with base branch: Merging can be performed automatically`,
is displayed, you can use the green `Merge pull request` button, or
change to `Squash and merge`.

Otherwise, the message `This branch has conflicts that must be resolved`
will be displayed: follow the instructions to resolve the conflicts.
Then push the button `Commit merge`. Then you should see
`No conflicts with base branch` and you can proceed as described in the
previous paragraph.

After a successful merge, you will see a message that you can delete the
`devel`-branch, which you can do. To do so later, go to `Pull requests`,
select the `closed` tab, and scroll down to the button `Delete branch`.

#### Overwrite devel-branch after merge

In RStudio, open the relevant project to check there are no commits
left. Then you can move to the `master` branch and `Pull` to get all
updates you just committed to the `master` branch. Then click the
`New branch` button in RStudio (besides the `Switch branch` icon
indicating which branch (e.g., `master` or `devel`) you are using), use
`devel` as branch name and click `Create`. You will be notified that
`devel` already exists and asked if you want to overwrite it. **If** you
have just merged `devel` into `master`, you can choose to overwrite it
to have a new `devel` branch.

#### Set up a new branch

Instead of overwriting the `devel`-branch after merging into `main`, you
can also create a completely new branch:

- At the GitHub page of the package: `Branch` icon \> green `New branch`
  button \> specify a name for the branch \> green `Create new branch`
  button.
- Go back to the GitHub page of the package, and at the green `Code`
  button \> `copy URL to clipboard`.
- In RStudio: `File` \> `New project` \> `Version control` \> `Git` and
  paste the copied URL in the `Repository URL` \> `Create Project`.
- Then (still in RStudio) in the `Git` menu change from `master` to the
  just-created branch.

### Installing the updated package

Then you can delete the old package version from your PC
(`find.package("<pkg>")` gives its location) and install the updated
version following your own instructions on the GitHub pages of the
relevant packages.

## Troubleshooting

To prevent `regex`-classes in example code from being interpreted as
links (which leads to the error
`@section Could not resolve link to topic ":blank:" in the dependencies or base packages`)
when running
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html),
use backticks (`` ` ``) to format a line as code, or wrap consecutive
lines in `` \code{...}` ``.

## Documentation and help

### Guidelines on package development

- The
  [`Writing R extensions`](https://cran.r-project.org/doc/manuals/r-release/R-exts.html)
  manual, which is the official guide on extending R
- The
  [`CRAN Repository policy`](https://cran.r-project.org/web/packages/policies.html)
  (with an overview of changes
  [here](https://github.com/eddelbuettel/crp)) and
  [`BioConductor package guide`](https://contributions.bioconductor.org/),
  which are the official guides for [CRAN](https://cran.r-project.org/)
  and [BioConductor](https://bioconductor.org/)
- The
  [`blueprints for software development`](https://epiverse-trace.github.io/blueprints/)
  from [EpiverseTrace](https://epiverse-trace.github.io/)
- The
  [`R development guide`](https://contributor.r-project.org/rdevguide/)
  from the [R Contribution Working
  Group](https://contributor.r-project.org/)
- The [`package development guide`](https://devguide.ropensci.org/), the
  [Statistical Software Peer
  Review](https://stats-devguide.ropensci.org/) guide, and a section
  [`Publish packages`](https://docs.r-universe.dev/publish.html) in the
  [`R universe documentation`](https://docs.r-universe.dev/) from
  [rOpenSci](https://ropensci.org/)

### Other useful resources

- The
  [`CRAN cookbook`](https://contributor.r-project.org/cran-cookbook/)
- The book [`R packages`](https://r-pkgs.org/) by Wickham and Bryan
- The book [`R in production`](https://r-in-production.org/) by Wickham
  and Masiello
- The chapter
  [`Building R Packages`](https://bookdown.org/rdpeng/RProgDA/building-r-packages.html)
  of
  [`Mastering Software Development in R`](https://bookdown.org/rdpeng/RProgDA/)
  by Peng, Kross, and Anderson
- The website
  [`What They Forgot to Teach You About R`](https://rstats.wtf/)
- The R [`developer page`](https://developer.r-project.org/) with
  [`developer guidelines`](https://developer.r-project.org/devel-guidelines.txt)
  and
  [`technical documentation`](https://developer.r-project.org/TechDocs/)
- The
  [`cheatsheet`](https://opensource.posit.co/resources/cheatsheets/package-development/)
  about package development by [Posit](https://posit.co/)
- The package
  [`checkrpkgs`](https://jessealderliesten.github.io/checkrpkgs/) that
  explains how to get information about to-be-installed and
  already-installed packages, and how to get the source code of R
  functions
- [`Package Development and Maintenance`](https://github.com/hturner/pkg-dev-ctv/blob/main/proposal.md)
  (currently a proposal for a
  [`CRAN Task View`](https://cran.r-project.org/web/views/)) with an
  annotated thematic collection of R packages that assist in developing
  R packages
- The R
  [`NEWS`](https://cran.r-project.org/doc/manuals/r-devel/NEWS.html) for
  the development branch
