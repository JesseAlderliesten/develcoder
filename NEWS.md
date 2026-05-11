# develcoder 0.0.3

### Breaking changes
- Add dependency `goodpractice` to be able to use `goodpractice::gp()` to check
  for various issues.
- Use `roxygen2` version 8.0.0.

### Miscellaneous
- Add pkgdown website: `https://jessealderliesten.github.io/develcoder/`.
- Vignette `Package development`: describe a faster way to create a new
  `devel`-branch. Replace deprecated `devtools::build_vignettes()` with
  `pkgdown::build_article()`.
- Vignette `Package setup`: add links to overviews of licenses.


# develcoder 0.0.2

### Breaking changes
- Add `fs` and `remotes` as dependencies in `Suggests` because they are used in
  `README_template.Rmd`.

### Miscellaneous
- Add references from `README_template.Rmd` to the vignettes.


# develcoder 0.0.1

- `develcoder` now is an R package.
