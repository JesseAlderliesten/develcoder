
# develcoder

Here I store code I use to develop [R](https://www.r-project.org/) packages.

The code makes heavy use of the R packages
[devtools](https://CRAN.R-project.org/package=devtools) and
[usethis](https://CRAN.R-project.org/package=usethis), following the
[R packages](https://r-pkgs.org/) book by Hadley Wickham and Jennifer Bryan.

For my unit tests I use [tinytest](https://CRAN.R-project.org/package=tinytest).

`develcoder` itself is *not* an R *package*: it is an R project, i.e., a
collection of scripts.

- `pkg_setup.R` contains code to set up a package from scratch. It will be
  needed only once for a package.
- `pkg_devel.R` contains code to use during package development. This is needed
  during package development, including when preparing to release a package and
  setting up for a new version.
- `NEWS_template.txt` contains a template for a NEWS file.

If you want to copy code from this repository, download it as a ZIP file (use
the green `Code` button and choose `Download ZIP`) and unzip the folder. You can
move the folder to your preferred location, but the R-scripts should be in the
same folder as the R-project file `develcoder.Rproj`.

