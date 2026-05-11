# Package development

## Introduction

This file contains code and annotations that are useful when developing
a package.

## Add functions

### Set up

``` r

usethis::use_r("is_number")
devtools::document() # also runs devtools::load_all()
?is_number() # view help-page of the function
```

Do:

- Manually update the `NEWS`-file.

### Documentation

``` r

#' Title
#'
#' Description
#'
#' @inheritParams is_logical # From a function in the current package
#' @inheritParams utils::installed.packages # from a function in another package
#' @param x Vector of names to test.
#' @param allow_underscores `TRUE` or `FALSE`: allow underscores?
#' @param x,y Separate arguments by a comma without a space to create a single
#' description for multiple arguments.
#'
#' @details
#'
#' @returns
#' `TRUE` or `FALSE`, returned [invisibly][invisible].
#'
#' @section Side effects:
#' Values in `x` are identified in an [error][stop], [warning], or [message] if
#' `signal` is `error`, `warn`, or `message`, respectively. Set `signal` to
#' `quiet` to suppress this.
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
func_name <- function(x, allow_underscores = TRUE) {
  stopifnot(checkinput::is_logical(allow_underscores))
  ...
}
```

#### Inherit sections

Inherited sections are *silently* ignored if that section is also
defined in the file itself.

``` r

#' @inherit is_number return
#' @inherit is_number details
#' @inheritSection is_logical Programming notes
#' @inheritSection is_logical @note
```

### Add tests

``` r

library(tinytest)
tinytest::test_all() # Run all tests of a package
tinytest::run_test_file("./inst/tinytest/test_funcname.R") # Run specific file

# expect_silent(...) tests that no warnings or errors are emitted, NOT that no
# messages are emitted.
expect_silent(expect_true(func_name(x = x, arg = arg)))
expect_warning(
  expect_equal(func_name(x = "a", arg = arg), 3),
  pattern = "...", strict = TRUE, fixed = TRUE)
expect_error(func_name(x = "a", arg = arg),
             pattern = "is_number(x) is not TRUE", fixed = TRUE)
```

### Using temporary files

- See
  [testthat::test_path()](https://testthat.r-lib.org/reference/test_path.html)
  on changing paths depending on how a check is run.
- On using temporary files, see
  [`local()`](https://rdrr.io/r/base/eval.html), this
  [R-mail](https://stat.ethz.ch/pipermail/r-devel/2018-March/075783.html),
  and
  [withr::with_tempfile()](https://withr.r-lib.org/reference/with_tempfile.html):

``` r
\dontshow{
  my_tempdir <- tempdir()
  example_dir <- file.path(my_tempdir, example_dir)
}
```

### Update dependencies

``` r

# Declare a minimum version for R itself
usethis::use_package("R", type = "Depends", min_version = "4.1.0")

# Declare a dependency on a package: 'use_package()' to declare a minimum
# version and 'use_dev_package()' to specify the remote repository to download
# the package from.
usethis::use_package(package = "checkinput", type = "Imports", min_version = TRUE)
usethis::use_dev_package(package = "checkinput", type = "Imports",
                         remote = "github::JesseAlderliesten/checkinput")
```

Do:

- Specify the minimum declared `R` version as workflow in GitHub
  Actions, see the section [Use GitHub Actions](#use-github-actions).

To use a function that is present in ‘new’ versions of R also in older
versions of R, see <https://github.com/yihui/xfun/blob/main/R/zzz.R>

#### Importing packages or functions

The standard way to use functions from other packages is to import the
package (i.e., put it in the `Imports:` field of the `DESCRIPTION` file)
and in code use the package name followed by two colons and the function
name, e.g.,
[`utils::osVersion()`](https://rdrr.io/r/utils/sessionInfo.html). If
that is not possible, for example because the function is an operator,
it is necessary to also list the function in the `NAMESPACE` file, e.g.,
to add the line `#' @importFrom utils osVersion` to
`R/<pkgname>-package.R` that was created by
[`usethis::use_package_doc()`](https://usethis.r-lib.org/reference/use_package_doc.html).
This is done by
`usethis::use_import_from(package = "utils", fun = "osVersion")`.

``` r

usethis::use_import_from(package = "utils", fun = "osVersion")
usethis::use_package("utils", type = "Suggests", min_version = "4.1.0")
```

## Add vignettes

### Set up

``` r

usethis::use_vignette("my_vignette", title = "Some title")
usethis::use_package(package = "knitr", type = "Suggests")
usethis::use_package(package = "rmarkdown", type = "Suggests")
devtools::document()
pkgdown::build_article()
browseVignettes(package = basename(getwd()))
```

If no vignettes are visible,
[`devtools::install()`](https://devtools.r-lib.org/reference/install.html)
was probably run with the default argument `build_vignettes = FALSE`,
use `build_vignettes = TRUE` instead:
`devtools::install(quick = FALSE, upgrade = FALSE, build_vignettes = TRUE)`.

See also `tools::pkgVignettes(package = "checkrpkgs")` and
`utils::vignette(<"vignette_title">)`. To render a `Rd`-file as
plain-text help in the R console: `tools::Rd2txt("path/to/file.Rd")`.

### Styling

See the vignette *RMarkdown and knitr*:
`vignette("RMarkdown and knitr", package = "develcoder")`) and my Chrome
Bookmarks: `R` \> `CreatePkgs` \> `RMarkdown` on using RMarkdown to
style vignettes.

Put the next lines in the header of vignettes to get a table of
contents:

``` r

output:
  rmarkdown::html_vignette:
  toc: true
toc_depth: 3
```

### Linking

For internal links to other sections in the same document (‘Section’,
‘above’, ‘below’): `[<Section title>]` or
`[<link text>][<Section title>]`

There is **no** official way to link from vignettes to help-pages
(<https://r-pkgs.org/vignettes.html#links>). Using relative paths (e.g.,
`[someFun](../help/someFun)`, as proposed in a [StackOverflow
answer](https://stackoverflow.com/questions/34946219)) is impaired by
the change in the location of files when the package is installed. In
addition, linking on the `pkgdown` website does **not** work in that
format. For more advanced way of linking from vignettes to help-pages
that might work, see
[here](https://github.com/dmurdoch/rgl/commit/bbc84447c2a6efed42907fbac176e9569b868d8f).

Text between angled brackets (e.g., `<pkgname>`) disappears when used in
link text, so instead of `[library(<pkgname>)](../help/library)`, use

``` r
[library](../help/library)`(<pkgname>)`
```

To link from help-pages to vignettes, use

``` r
The vignette *<vignette name>*: `vignette("<vignette name>", package = "<pkgname>")` 
```

If no vignettes are visible, run
[`pkgdown::build_article()`](https://pkgdown.r-lib.org/reference/build_articles.html),
which possibly needs to be followed by
`install(..., build_vignettes = TRUE)`.

## Adding miscellaneous files

Non-standard files or folders should be added in the `inst/` directory
to pass `R cmd check`. Those files and folders will be in the top
directory in the installed package.

## Preparing for updates

### Check tests

Check for which functions no test file has been written.

``` r

devtools::document()
tinytest::test_all()

files_R <- list.files(file.path(".", "R"))
files_man <- list.files(path = file.path(".", "man"), pattern = "\\.Rd$")
expected_man <- sub(pattern = "\\.Rd$", replacement = ".R", x = files_man)
expected_files <- sort(unique(paste0("test_", c(files_R, expected_man))))
expected_files[!(expected_files %in% list.files("./inst/tinytest"))]
```

### Locally test update

``` r

devtools::document()
# Using `manual = FALSE` because building the manual leads to `latex` errors
devtools::check(manual = FALSE, force_suggests = TRUE, run_dont_test = TRUE)
.libPaths() # Check if output of .libPaths() is correct.
devtools::install(quick = FALSE, upgrade = FALSE, build_vignettes = TRUE)

# Note:
# The lintr issue `Use == instead of %in% for scalar comparison` should be
# ignored for x %in% y if x or y might contain NA that should be ignored:
# x %in% NA and NA %in% y return FALSE, whereas x == NA and NA == y return NA
goodpractice::gp() # Check for issues.

# Load the package and view the help files as usual outside devtools:
library(basename(getwd()), character.only = TRUE)
browseVignettes(package = basename(getwd()))
?reorder_levels
```

If no vignettes are visible,
[`devtools::install()`](https://devtools.r-lib.org/reference/install.html)
was probably run with the default `build_vignettes = FALSE`: change it
to use `build_vignettes = TRUE`.

### Update package-wide documentation

#### NEWS

Restyle and publish the `NEWS`-file at each new package release.

#### README

To provide a nice overview of functions: see [this
example](https://github.com/MJobinASU/MontyHall). After adjusting the
`README.Rmd`, `Knit` it to produce a `README.Md` file.

#### Increment package version

To increment the package version, adjust the package version in the
`DESCRIPTION` file, or run `R` as administrator and then use
[`usethis::use_version()`](https://usethis.r-lib.org/reference/use_version.html).
In the latter case, do not automatically `commit` the change, but do so
manually to adjust the commit message to something like
`Bump to version x.y.z. Breaking change: <func> no longer ...`.
Indicating the version number in the commit title makes it easier to
find back changes later on.

## Performing updates

### Use GitHub Actions

To manually run GitHub Actions (GHA) set up `workflow_dispatch` (see
section `Use GitHub Actions` in `pkg_setup.Rmd`). To check if package
`B`, which depends on package `A`, is still working fine, go to the
`Actions` tab of repository `B`, select the action you want to trigger
(e.g., `R-CMD-check.yaml`), and use the `Run workflow` button to run the
GHA. You can select which branch it should run on, but you need to
trigger it once manually on the `main` branch to be able to trigger it
manually on other branches.

Scheduled jobs that failed can be rerun through the button `Re-run jobs`
\> `Re-run failed jobs` \> `Re-run jobs`.

If the package declares a dependency on a specific `R` version, it is
useful to specify the minimum declared `R` version to run in addition to
the ones that are by default used in the template: add
`- {os: ubuntu-latest, r: '4.1.0'}` to section `matrix: config:` to run
`R` 4.1.0.

### Update pkgdown website

See the documentation about package
[pkgdown](https://pkgdown.r-lib.org/) and the
[chapter](https://r-pkgs.org/website.html) from the R packages book.

Updating website

``` r

pkgdown::build_site()
```

Open `docs/index.html` in a webbrowser to preview the website, or look
at the files that constitute your package’s website are in the local
`docs/` directory.

Instead of manually updating the pkgdown website, one can use a [GitHub
Action](#use-github-actions) workflow (e.g.,
[pkgdown.yaml](https://github.com/JesseAlderliesten/develcoder/blob/main/.github/workflows/pkgdown.yaml))
that updates the website after a pull request or push.

### Merge devel-branch with master

To merge the `devel`-branch with `master`, go the the `devel`-branch on
GitHub. `<Contribute>` \> `Open Pull Request`. Copy the updated `NEWS`
in the `description` field and use the button `Create pull request`.

If you see
`No conflicts with base branch: Merging can be performed automatically`,
you can use the green `Merge pull request` button, or change to
`Squash and merge`.

Otherwise, you will see
`This branch has conflicts that must be resolved`: follow the
instructions to resolve the conflicts. Then push the button
`Commit merge`. Then you should see `No conflicts with base branch` and
you can proceed as described in the previous paragraph.

After a successful merge, you will see a message that you can delete the
`devel`-branch, which you can do. To do so later, go to `Pull requests`,
select the `closed` tab, and scroll down to the button `Delete branch`.

### Overwrite devel-branch after merge

In `RStudio`, open the relevant project to check there are no commits
left. Then you can move to the `master` branch and `Pull` to get all
updates you just committed to the `master` branch. Then click the
`New branch` button in `RStudio` (besides the `Switch branch` icon
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
- In `RStudio`: `File` \> `New project` \> `Version control` \> `Git`
  and paste the copied URL in the `Repository URL` \> `Create Project`.
- Then (still in `RStudio`) in the `Git` menu change from `master` to
  the just-created branch.

### Installing the updated package

Then you can delete the old package version from your PC (see
[`getwd()`](https://rdrr.io/r/base/getwd.html) for its location) and
install the updated version following your own instructions on the
GitHub pages of the relevant packages.

## Troubleshooting

To prevent `regex`-classes in example code from being interpreted as
links (which leads to the error
`@section Could not resolve link to topic ":blank:" in the dependencies or base packages`)
when running
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html),
use backticks
(`) to format a line as code, or wrap consecutive lines in`\`.

## Guidelines

See <https://developer.r-project.org/> and
<https://developer.r-project.org/devel-guidelines.txt> See alsoe
<https://cran.r-project.org/web/packages/policies.html> and
<https://github.com/JesseAlderliesten/pkg-dev-ctv/blob/main/proposal.md#links-links>
