
<!-- README.md is generated from README.Rmd. Please edit that file -->

# develcoder

<!-- badges: start -->

![](https://img.shields.io/github/r-package/v/JesseAlderliesten/develcoder?color=blue)
[![R-CMD-check](https://github.com/JesseAlderliesten/develcoder/actions/workflows/check-standard.yaml/badge.svg)](https://github.com/JesseAlderliesten/develcoder/actions/workflows/check-standard.yaml)
[![R-CMD-check-no-suggests](https://github.com/JesseAlderliesten/develcoder/actions/workflows/check-no-suggests.yaml/badge.svg)](https://github.com/JesseAlderliesten/develcoder/actions/workflows/check-no-suggests.yaml)
<!-- badges: end -->

`develcoder` is an [R](https://www.r-project.org/) package containing
code and templates to develop R packages. It is based on the book
[`R packages`](https://r-pkgs.org/) by Hadley Wickham and Jennifer
Bryan, using R packages
[`devtools`](https://CRAN.R-project.org/package=devtools) and
[`usethis`](https://CRAN.R-project.org/package=usethis). I use
[`tinytest`](https://CRAN.R-project.org/package=tinytest) instead of
[`testthat`](https://cran.r-project.org/package=testthat) for unit
tests.

## Structure

Folder `vignettes` contains the following vignettes:

- [`package setup`](https://jessealderliesten.github.io/develcoder/articles/pkg_setup.html)
  `vignette("pkg_setup", package = "develcoder")` contains code that is
  needed only once to set up a package from scratch.
- [`package development`](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html)
  `vignette("pkg_devel", package = "develcoder")` contains code that is
  useful during package development, including when preparing to release
  a new package version and setting up for a new version.
- [`R Markdown and knitr`](https://jessealderliesten.github.io/develcoder/articles/rmarkdown_knitr.html)
  `vignette("rmarkdown_knitr", package = "develcoder")` contains
  information about using
  [`R Markdown`](https://pkgs.rstudio.com/rmarkdown/) and
  [`knitr`](https://yihui.org/knitr/).

Folder
[`inst/templates`](https://github.com/JesseAlderliesten/develcoder/tree/main/inst/templates)
contains the following templates (in the installed package these are in
`develcoder/templates`):

- `README_template.Rmd` for a `README.Rmd` file, to be put in the
  top-directory of `<pkg>`.
- `check-no-suggests.yaml` for a GitHub Actions workflow checking if the
  package code can be run if the suggested packages are **not**
  installed
- `check-standard.yaml` for a GitHub Actions workflow
- `pkgdown.yaml` for a GitHub Actions workflow to update the package
  website

To use these files, put the `README.Rmd` file in the top-directory of
`<pkg>`. The `yaml` files should be put in `<pkg>\.github\workflows`
(see the section `Automate checks` in the vignette [package
setup](https://jessealderliesten.github.io/develcoder/articles/pkg_setup.html)
and the section `Use GitHub Actions` in the vignette [package
development](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html)
for details).

## Installation

Visit the [develcoder
website](https://jessealderliesten.github.io/develcoder/) to explore the
package, or install `develcoder` from
[GitHub](https://github.com/JesseAlderliesten/develcoder) using the
following R code:

``` r
if(!requireNamespace("remotes")) {
   install.packages(pkgs = "remotes")
}
remotes::install_github(repo = "JesseAlderliesten/develcoder",
                        upgrade = FALSE, build_vignettes = TRUE, lib = NULL)
```

For more information about installing and configuring R and RStudio, see
my package
[`checkrpkgs`](https://jessealderliesten.github.io/checkrpkgs/).

## License

This project is licensed under the terms of the [MIT
License](LICENSE.md).

## Citation

    To cite package 'develcoder' in publications use:

      Alderliesten J (2026). _develcoder: Code and Templates to Develop R
      Packages_. R package version 0.9.0,
      <https://github.com/JesseAlderliesten/develcoder>.

    A BibTeX entry for LaTeX users is

      @Manual{,
        title = {develcoder: Code and Templates to Develop R Packages},
        author = {Jesse Alderliesten},
        year = {2026},
        note = {R package version 0.9.0},
        url = {https://github.com/JesseAlderliesten/develcoder},
      }

## Similar resources

- The book [`R packages`](https://r-pkgs.org/) by H. Wickham and J.
  Bryan
- The chapter
  [`Building R Packages`](https://bookdown.org/rdpeng/RProgDA/building-r-packages.html)
  of
  [`Mastering Software Development in R`](https://bookdown.org/rdpeng/RProgDA/)
  by R. D. Peng, S. Kross, and B. Anderson.
- Slides from the workshop [Building tidy
  tools](https://rstudio-conf-2022.github.io/build-tidy-tools/) by E.
  Rand and I. Lyttle
- The section `Documentation and help` in the
  [`package development`](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html)
  vignette contains further references.
- Package [`packagepal`](https://CRAN.R-project.org/package=packagepal)
