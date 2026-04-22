# develcoder

Here I store code and templates I use to develop [R](https://www.r-project.org/)
packages. The code makes heavy use of the R packages
[devtools](https://CRAN.R-project.org/package=devtools) and
[usethis](https://CRAN.R-project.org/package=usethis), following the
[R packages](https://r-pkgs.org/) book by Hadley Wickham and Jennifer Bryan. I
use [tinytest](https://CRAN.R-project.org/package=tinytest) instead of
[testthat](https://cran.r-project.org/package=testthat) for my unit tests.

`develcoder` itself is not an R *package* but an R *project*, i.e., a collection
of R scripts.

## Structure
The project consists of two scripts and a collection of templates:

- `pkg_setup.R` contains code to set up a package from scratch. It will be
  needed only once for a package.
- `pkg_devel.R` contains code to use during package development. This is needed
  during package development, including when preparing to release a package and
  setting up for a new version.
- `rmarkdown_knitr.txt` contains information about using
  [R Markdown](https://pkgs.rstudio.com/rmarkdown/) and
  [knitr](https://yihui.org/knitr/).

Folder `templates` contains the following templates:

- `NEWS_template.txt` for a `NEWS.txt` file, to be put in `<pkgname>`.
- `README_template.Rmd` for a `README.Rmd` file, to be put in `<pkgname>`.
- `check-no-suggests.yaml` for a GitHub Actions workflow, to be put in
  `<pkgname>\.github\workflows` (see section `Use GitHub Actions` in files
  `pkg_setup.R` and `pkg_devel.R` for details).

## Workflow
If you want to copy code from this repository, download it as a ZIP file (use
the green `Code` button and choose `Download ZIP`) and unzip the folder. You can
move the folder to your preferred location, but the R-scripts should be in the
same folder as the R-project file `develcoder.Rproj`.

## Troubleshooting
For information about installing and configuring [R](https://www.r-project.org/)
and [RStudio](https://posit.co/products/open-source/rstudio), see my repository
[checkrpkgs](https://github.com/JesseAlderliesten/checkrpkgs).
