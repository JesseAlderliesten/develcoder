# Changelog

## develcoder 0.0.6

#### Breaking changes

- Add suggested dependencies `codetools` and `pkgcheck` for package
  checks.

#### Miscellaneous

- Vignette `Package development`: add section about automated checks.

## develcoder 0.0.5

#### Miscellaneous

- Vignettes: Stylistic updates (fix and add links).
- Vignette `Package development`: add section about styling the
  `pkgdown` website. Elaborate on linking on the `pkgdown` website and
  on failed GitHub Actions.

## develcoder 0.0.4.

#### Miscellaneous

- `README`: refer to website when appropriate. Stylistic update.
- `NEWS`: stylistic update.
- Vignettes: rely on `pkgdown` to create links to functions.

## develcoder 0.0.3

#### Breaking changes

- Add dependency `goodpractice` to be able to use
  [`goodpractice::gp()`](https://docs.ropensci.org/goodpractice/reference/gp.html)
  to check for various issues.
- Use `roxygen2` version 8.0.0.

#### Miscellaneous

- Add pkgdown website:
  `https://jessealderliesten.github.io/develcoder/`.
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

#### Miscellaneous

- Add references from `README_template.Rmd` to the vignettes.

## develcoder 0.0.1

- `develcoder` now is an R package.
