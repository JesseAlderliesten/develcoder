# Check base dependencies

Check base dependencies

## Usage

``` r
check_base_deps(path = ".")
```

## Arguments

- path:

  [character
  string](https://jessealderliesten.github.io/checkinput/reference/all_characters.html)
  containing a valid
  [path](https://jessealderliesten.github.io/checkinput/reference/is_path.html)
  to the folder with the package of which the
  [DESCRIPTION](https://desc.r-lib.org/reference/description.html) file
  should be checked. The default is the [working
  directory](https://rdrr.io/r/base/getwd.html).

## Value

A [data frame](https://rdrr.io/r/base/data.frame.html) with the
[dependencies](https://desc.r-lib.org/reference/desc_get_deps.html) on
R, base packages and recommended packages as listed in the DESCRIPTION
file, returned [invisibly](https://rdrr.io/r/base/invisible.html). A
zero-row data frame is returned if such dependencies are not present.

The data frame has the following columns:

- `type` giving the type of dependency, e.g., `Imports`, `Depends`,
  `Suggests`

- `package` giving the package name or `"R"`

- `version` giving the version specification, e.g., `">= 4.0.0"`, with
  `*` if no version is declared

## Details

Package [`base`](https://rdrr.io/r/base/base-package.html) should
**not** be listed in the DESCRIPTION file: it is always loaded. See the
`Examples` how to list a dependency on R using
[`usethis::use_package()`](https://usethis.r-lib.org/reference/use_package.html).

A package can occur more than once within a single type of dependency
(e.g., `Imports`, `Depends`, `Suggests`) to indicate a range, e.g.,
`<pkg A> (>= 3.6.0)` and `<pkg A> (<= 4.4.0)`. However, each package
should be listed in only one of the types of dependencies, otherwise an
error is thrown.

It is **not** required to declare version numbers for the
[base](https://cran.r-project.org/doc/FAQ/R-FAQ.html#Add_002don-packages-in-R)
or
[recommended](https://cran.r-project.org/doc/FAQ/R-FAQ.html#Add_002don-packages-from-CRAN)
packages. If version numbers are declared, they should contain at least
a major and minor level. [Warnings](https://rdrr.io/r/base/warning.html)
are issued if different minimum versions are declared for those
packages, or if they declare minimum versions that differ from the
declared earliest version of R if that is present.

If `"R"` is listed in the DESCRIPTION file, it should:

- be in field `"Depends"`

- declare at least one minimum version number

- **not** declare a version earlier than any declared minimum versions
  of the base or recommended packages

- contain at least a major and minor level, e.g., `R (>= 4.0)` or
  `R (>= 4.1)`

- use `0` as patch level (i.e., as third digit in the version number) if
  it is present: `R (>= 4.4.0)` or `R (>= 4.4)` instead of
  `R (>= 4.4.1)`, otherwise a warning is issued.

## Examples

``` r
if(requireNamespace("withr", quietly = TRUE)) {
  tempdir_example <- progutils::create_tempdir(
    prefix = "check_base_deps")

  withr::with_dir(new = tempdir_example, {
    # Create a DESCRIPTION file
    desc <- desc::description$new("!new")
    desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))

    # Use package 'usethis' to add R with
    # a minimum version in 'Depends'
    if(requireNamespace("usethis", quietly = TRUE)) {
      usethis::use_package(
        "R", type = "Depends", min_version = "4.0.0")
      (check_base_deps(tempdir_example))
    }

    # Create a new DESCRIPTION file
    desc <- desc::description$new("!new")
    desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))

    # Use package 'desc' to add R with
    # a minimum version in 'Depends'
    desc <- desc::desc_set_dep(
      "R", type = "Depends", version = ">= 4.0.0")
    (check_base_deps(tempdir_example))

    # Add package 'checkinput'
    desc <- desc::desc_set_dep("checkinput", type = "Depends")
    # 'checkinput' is not among the returned packages
    # because it is not a 'base' or 'recommended' package.
    (check_base_deps(tempdir_example))

    # Add package 'tools' (a 'base' package)
    # with an earlier minimum version than 'R'
    desc <- desc::desc_set_dep(
      "tools", type = "Depends", version = ">= 3.6.0")
    (check_base_deps(tempdir_example)) # silent

    # Add package 'utils' (a 'base' package)
    # with a later minimum version than 'R'
    desc <- desc::desc_set_dep(
      "utils", type = "Depends", version = ">= 4.1.0")
    # An error that the declared minimum version of R is
    # earlier than the declared minimum version of 'utils':
    try(check_base_deps(tempdir_example))

    # A new DESCRIPTION file without dependencies
    desc <- desc::description$new("!new")
    desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
    # Silently returns a zero-row data frame
    (check_base_deps(tempdir_example))

    # R without minimum version in 'Depends'
    desc <- desc::description$new("!new")
    desc$write(file = fs::path(tempdir_example, "DESCRIPTION"))
    desc <- desc::desc_set_dep("R", type = "Depends")
    try(check_base_deps(tempdir_example)) # Error
  })

  # Remove temporary directory
  unlink(tempdir_example, recursive = TRUE)
}
#> ✔ Setting active project to "/tmp/Rtmp4rKr7e/check_base_deps1b5415c8efb1".
#> ✔ Adding R to Depends field in DESCRIPTION.
#> Error in check_base_deps(tempdir_example) : 
#>   The DESCRIPTION file lists a declared minimum version of 'R' that
#> is earlier than declared minimum versions of base or recommended packages:
#> R >= 4.0.0 with utils: >= 4.1.0
#> Error in check_base_deps(tempdir_example) : 
#>   Indicate a minimum version number for 'R' if you list it in the DESCRIPTION
#> file, e.g., 'R (>= 4.6)'. Currently the following versions are indicated:
#> '*'
```
