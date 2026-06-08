# develcoder

`develcoder` is an [R](https://www.r-project.org/) package containing
code and templates to develop R packages. It is based on the [R
packages](https://r-pkgs.org/) book by Hadley Wickham and Jennifer
Bryan, using R packages
[devtools](https://CRAN.R-project.org/package=devtools) and
[usethis](https://CRAN.R-project.org/package=usethis), although I use
[tinytest](https://CRAN.R-project.org/package=tinytest) instead of
[testthat](https://cran.r-project.org/package=testthat) for unit tests.

## Structure

    ├── .github
    │   └── workflows: workflows to run tests with GitHub Actions
    ├── R: functions and package overview
    ├── inst
    │   ├── templates: templates for README and yaml files (see below).
    │   └── tinytest: tests
    ├── man: help-files
    ├── tests: setup to use 'tinytest' for testing
    └── vignettes: vignettes (see below) 

Folder
[inst/templates](https://github.com/JesseAlderliesten/develcoder/tree/main/inst/templates)
contains the following templates (in the installed package these are in
`develcoder/templates`):

- `README_template.Rmd` for a `README.Rmd` file, to be put in
  `<pkgname>`.
- `check-no-suggests.yaml` for a GitHub Actions workflow, to be put in
  `<pkgname>\.github\workflows` (see the section `Automate checks` in
  the vignette [package
  setup](https://jessealderliesten.github.io/develcoder/articles/pkg_setup.html)
  and the section `Use GitHub Actions` in the vignette [package
  development](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html)
  for details).

Folder `vignettes` contains the following vignettes:

- [package
  setup](https://jessealderliesten.github.io/develcoder/articles/pkg_setup.html)
  [`vignette("pkg_setup", package = "develcoder")`](https://jessealderliesten.github.io/develcoder/articles/pkg_setup.md)
  contains code that is needed only once to set up a package from
  scratch.
- [package
  development](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html)
  [`vignette("pkg_devel", package = "develcoder")`](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.md)
  contains code that is useful during package development, including
  when preparing to release a new package version and setting up for a
  new version.
- [R Markdown and
  knitr](https://jessealderliesten.github.io/develcoder/articles/rmarkdown_knitr.html)
  [`vignette("rmarkdown_knitr", package = "develcoder")`](https://jessealderliesten.github.io/develcoder/articles/rmarkdown_knitr.md)
  contains information about using [R
  Markdown](https://pkgs.rstudio.com/rmarkdown/) and
  [knitr](https://yihui.org/knitr/).

## Installation

Visit the [develcoder
website](https://jessealderliesten.github.io/develcoder/) to explore the
package, or install `develcoder` from
[GitHub](https://github.com/JesseAlderliesten/develcoder) using the
following R code (you need to run R as administrator):

``` r

if(!requireNamespace("remotes", quietly = TRUE)) {
  install.packages(pkgs = "remotes", quiet = FALSE)
}
remotes::install_github(repo = "JesseAlderliesten/develcoder",
                        dependencies = NA, upgrade = FALSE, force = FALSE,
                        quiet = FALSE, build_vignettes = TRUE, lib = NULL,
                        verbose = getOption("verbose"))
```

For more information about installing and configuring R and RStudio, see
my package
[checkrpkgs](https://jessealderliesten.github.io/checkrpkgs/).

## Similar resources

- The book [R packages](https://r-pkgs.org/) by H. Wickham and J. Bryan
- The chapter [Building R
  Packages](https://bookdown.org/rdpeng/RProgDA/building-r-packages.html)
  of [Mastering Software Development in
  R](https://bookdown.org/rdpeng/RProgDA/) by R. D. Peng, S. Kross,
  and B. Anderson.
- The section ‘Documentation and help’ in the [package
  development](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html)
  vignette contains further references.

## License

This project is licensed under the terms of the [MIT
License](https://jessealderliesten.github.io/LICENSE.md).

## Citation

Please cite this project [as described
here](https://jessealderliesten.github.io/CITATION)
