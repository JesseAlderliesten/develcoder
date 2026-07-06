# Changelog

## develcoder 0.9.0

#### Breaking changes

- `check_test_files()`: renamed to `check_tests`, with major overhaul to
  work with
  [`diagnose_test_infra()`](https://jessealderliesten.github.io/develcoder/reference/diagnose_test_infra.md)
  and
  [`diagnose_test_files()`](https://jessealderliesten.github.io/develcoder/reference/diagnose_test_files.md)
  and include various additional checks.
- `check_test_infra()` and `get_test_files()`: renamed to
  [`diagnose_test_infra()`](https://jessealderliesten.github.io/develcoder/reference/diagnose_test_infra.md)
  and
  [`diagnose_test_files()`](https://jessealderliesten.github.io/develcoder/reference/diagnose_test_files.md),
  with major overhauls to use them more easily in `check_test_files()`.
  For `get_test_files()`, warn about ignored files and respect argument
  `ignore_case`.

#### Documentation

- Vignette `pkg_devel`: URLs should use protocol `https://` instead of
  `http://`, not the other way around. Point out to install the package
  before knitting the `README`. Expand info on checking reverse
  dependencies. Some change in overall structure.

## develcoder 0.8.0

#### Breaking changes

- Dependency `desc`: move from `Suggests` to `Imports` because it is
  used by `check_test_infra()`.
- Dependency `fs`: require minimum version `1.2.4` because function
  `dir_ls()` with argument `fail` is used in a vignette.
- Suggested dependency `goodpractice`: require minimum version `1.1.0`
  which changed default argument `checks` in
  [`goodpractice::goodpractice()`](https://docs.ropensci.org/goodpractice/reference/gp.html).
- Dependency `progutils`: increase minimum version from `0.9.0` to
  `0.13.0` to prevent spurious warnings from `wrap_text()`.
- Dependency `remotes`: require minimum version `2.2.0` because function
  `install_version()` with the specification of minimum version is used
  in a vignette.
- Add suggested dependency `withr` to create temporary projects when
  testing.

#### Added functions

- `check_test_infra()` to check if the infrastructure for testing is
  present and refers to the current package.

#### Documentation

- Vignette `pkg_setup`: expand section on licenses. Move documentation
  on GitHub Actions to vignette `pkg_devel`.
- Vignette `pkg_devel`: discuss choosing dependencies. Add section with
  documentation and help for GitHub Actions. Explain how to show the
  `DESCRIPTION` file when discussing how to normalise it. Various
  clarifications.
- Vignette `rmarkdown_knitr`: fuller discussion of R markdown file and
  package.

## develcoder 0.7.0

#### Breaking changes

- Dependencies `checkinput`, `fs`, and `progutils`: move from `Suggests`
  to `Imports` because they are used by `missing_test_files()`,
  increasing minimum version for `progutils` from `>= 0.5.0` to
  `>= 0.9.0` to use a safe version of `create_tempdir()`.
- Add dependency `testthat` to `Suggests` because it is mentioned in a
  vignette.
- Remove dependency `pkgcheck` because their checks are already covered
  by `goodpractice`.

#### Added functions

- `check_test_files()` to check if all function files have a
  corresponding test file and vice versa.
- `get_test_files()`: helper function for `check_test_files()`.

#### Documentation

- Vignette `pkg_setup`: explain how to use `testthat` instead of
  `tinytest`. Add a clearer introduction to `pkgdown`.
- Vignette `pkg_devel`: various additions: explain how to not run or not
  display code in examples. Elaborate explanation how to find when a
  feature was introduced. Elaborate section `Automated checks`. No
  longer suggest using `pkgcheck` which requires system libraries.
- Vignette `rmarkdown_knitr`: expand section with examples of
  formatting, showing both the code and the output.

## develcoder 0.6.0

#### Breaking changes

- Add dependency `desc` to `Suggests` because it is used in a vignette.
- Dependency `checkrpkgs`: require minimum version `1.0.0` to depend on
  a stable version.

## develcoder 0.5.0

#### Breaking changes

- Dependency `checkinput`: require minimum version `1.0.0` to depend on
  a stable version.

#### Documentation

- Remove old `NEWS`.
- Section ‘Add package-wide documentation’: put code closer to remarks.

## develcoder 0.4.0

#### Breaking changes

- Dependency `progutils`: increase minimum version from `0.2.0` to
  `0.5.0` to prevent
  [`progutils::create_dir()`](https://jessealderliesten.github.io/progutils/reference/create_dir.html)
  from unsafely returning the working directory if creating the
  directory fails.
- Dependencies `checkinput` and `checkrpkgs`: remove unnecessary
  requirements for a minimum version.

## develcoder 0.3.0

#### Breaking changes

- Add dependencies `revdepcheck` and `xfun` to `Imports` because they
  are used in a vignette to check reverse dependencies.

#### Documentation

- Vignette `Package setup`: remove section ‘Importing packages or
  functions’ because it duplicates section ‘Update dependencies’ from
  the vignette `Package development`.
- Vignette `Package development`: add section ‘Check reverse
  dependencies’.
- Remove the `NEWS` template: looking at real `NEWS` files is much more
  useful.

## develcoder 0.2.0

#### Breaking changes

- Dependencies: increase minimum version of `checkinput` from `0.7.0` to
  `0.8.0`, of `progutils` from `0.0.9` to `0.2.0`, and of `checkrpkgs`
  to `>= 0.9.0` to update argument name `allow_zero` to
  `allow_zero_length`.
