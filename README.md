<!-- badges: start -->

![](https://img.shields.io/github/r-package/v/JesseAlderliesten/develcoder?color=blue)
[![R-CMD-check](https://github.com/JesseAlderliesten/develcoder/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/JesseAlderliesten/checkrpkgs/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

# develcoder

`develcoder` is an R package where I store code and templates used to develop
[R](https://www.r-project.org/) packages. It makes heavy use of the R packages
[devtools](https://CRAN.R-project.org/package=devtools) and
[usethis](https://CRAN.R-project.org/package=usethis), following the
[R packages](https://r-pkgs.org/) book by Hadley Wickham and Jennifer Bryan. I
use [tinytest](https://CRAN.R-project.org/package=tinytest) instead of
[testthat](https://cran.r-project.org/package=testthat) for my unit tests.

## Structure
```
├── .github
│   └── workflows: workflows to run tests with GitHub Actions
├── R: functions
├── inst
│   ├── templates: templates for NEWS, README, and yaml files (see below).
│   └── tinytest: tests
├── man: help-files
├── tests: setup to use 'tinytest' for testing
└── vignettes: vignettes (see below) 
```

The following templates are present in `inst/templates` (in the installed
package these are in `<pkgname>/templates`):

- `NEWS_template.txt` for a `NEWS.txt` file, to be put in `<pkgname>`.
- `README_template.Rmd` for a `README.Rmd` file, to be put in `<pkgname>`.
- `check-no-suggests.yaml` for a GitHub Actions workflow, to be put in
  `<pkgname>\.github\workflows` (see section `Use GitHub Actions` in files
  `pkg_setup.Rmd` and `pkg_devel.Rmd` for details).

The following vignettes are present in folder `vignettes`:

- `pkg_setup.Rmd` contains code to set up a package from scratch. It will be
  needed only once for a package.
- `pkg_devel.Rmd` contains code to use during package development. This is needed
  during package development, including when preparing to release a package and
  setting up for a new version.
- `rmarkdown_knitr.Rmd` contains information about using
  [R Markdown](https://pkgs.rstudio.com/rmarkdown/) and
  [knitr](https://yihui.org/knitr/).

## Installation

You can install `develcoder` from
[GitHub](https://github.com/JesseAlderliesten/develcoder) with:

``` r
if(!requireNamespace("remotes", quietly = TRUE)) {
  install.packages(pkgs = "remotes", quiet = FALSE)
}
remotes::install_github(repo = "JesseAlderliesten/develcoder", dependencies = TRUE,
                        upgrade = FALSE, force = FALSE, quiet = FALSE,
                        build_vignettes = TRUE, lib = NULL,
                        verbose = getOption("verbose"))
```

For information about installing and configuring R and RStudio, see my
repository [checkrpkgs](https://github.com/JesseAlderliesten/checkrpkgs).
