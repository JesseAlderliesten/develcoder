# Changelog

## develcoder 0.2.0

#### Breaking changes

- Dependency `checkinput`: increase minimum version from `0.7.0` to
  `0.8.0` to update argument name `allow_zero` to `allow_zero_length`.
- Dependency `progutils`: increase minimum version from `0.0.9` to
  `0.2.0` to update argument name `allow_zero` to `allow_zero_length`.
- Dependency `checkrpkgs`: require \>= 0.9.0 to update argument name
  `allow_zero` to `allow_zero_length`.

#### Documentation

- Updated package description.
- Also use first-level headings.
- Vignette `Package development`: expand section ‘Documentation and
  help’. Returning an error is not a side effect. Add option to run
  individual test files.
- `README`: add section ‘Similar resources’.

## develcoder 0.1.0

#### Breaking changes

- Dependency `checkinput`: require \>= 0.6.0, needed to use
  `paste_quoted()` that is re-exported from `checkinput` to `progutils`.
- Dependency `progutils`: require \>= 0.0.9, needed to use
  `paste_quoted()` that is re-exported from `checkinput` to `progutils`.

## develcoder 0.0.7

#### Documentation

- Vignette `Package development`: add a section on writing examples.
  Moved stub on temporary files to section `Usage in practice` of
  [`progutils::create_tempdir()`](https://jessealderliesten.github.io/progutils/reference/create_tempdir.html).
  Add a section on creating a custom function index for the package
  website. Rename default GitHub branch from `master` to `main`.

## develcoder 0.0.6

#### Breaking changes

- Add suggested dependencies `codetools` and `pkgcheck` for package
  checks.

#### Documentation

- Vignette `Package development`: add section about automated checks.

## develcoder 0.0.5

#### Documentation

- Vignette `Package development`: add section about styling the
  `pkgdown` website. Elaborate on linking on the `pkgdown` website and
  on failed GitHub Actions.

## develcoder 0.0.3

#### Breaking changes

- Add dependency `goodpractice` to be able to use
  [`goodpractice::gp()`](https://docs.ropensci.org/goodpractice/reference/gp.html)
  to check for various issues.
- Use `roxygen2` version 8.0.0.

#### Documentation

- Vignette `Package development`: describe a faster way to create a new
  `devel`-branch. Replace deprecated
  [`devtools::build_vignettes()`](https://devtools.r-lib.org/reference/build_vignettes.html)
  with
  [`pkgdown::build_article()`](https://pkgdown.r-lib.org/reference/build_articles.html).
- Vignette `Package setup`: add links to overviews of licenses.

## develcoder 0.0.2

#### Breaking changes

- Add `fs` and `remotes` as dependencies in `Suggests` because they are
  used in `README_template.Rmd`.

## develcoder 0.0.1

- `develcoder` now is an R package.
