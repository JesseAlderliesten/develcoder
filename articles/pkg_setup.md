# Package setup

## Introduction

This vignette contains code and annotations to create a package. This
code is needed only once to set up a package from scratch. Further
package development is described in the vignette *Package development*:
[`utils::vignette("pkg_devel", package = "develcoder")`](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html).

## Check existing packages

To search for functionality in existing packages, see the pointers given
at the CRAN task view [Package
Development](https://CRAN.R-project.org/view=PackageDevelopment#checking-the-package-landscape),
the [search page](https://r-universe.dev/) of R-universe which is also
available with [AI-assisted extended search
capabilities](https://rwarehouse.netlify.app/), and packages
[**pkgmatch**](https://CRAN.R-project.org/package=pkgmatch) and
[**pkgsearch**](https://CRAN.R-project.org/package=pkgsearch). Section
[R
packages](https://jessealderliesten.github.io/checkrpkgs/articles/r_pkgs.html#r-packages)
in the vignette *R packages* from package
[**checkrpkgs**](https://jessealderliesten.github.io/checkrpkgs/) gives
an overview of repositories containing R packages:
[`utils::vignette("r_pkgs", package = "checkrpkgs")`](https://jessealderliesten.github.io/checkrpkgs/articles/r_pkgs.html).

## Choose a name

``` r

pkgname <- "mypkgname"

# Is the intended name valid?
pkgname_valid <- pkgdepends::is_valid_package_name(nm = pkgname)
if(!pkgname_valid) {
  stop("Package name ", progutils::paste_quoted(pkgname), " is not valid: ",
       attr(pkgname_valid, which = "reason"))
}

# Is the intended name available?
unlist(pkgdepends::pkg_name_check(name = pkgname)$basics)
utils::browseURL(url = paste0("https://github.com/search?q=", pkgname,
                              "&type=repositories"))
utils::browseURL(url = paste0("https://github.com/search?q=", pkgname,
                              "+language%3AR+&type=repositories"))
```

## Create the package

The code below creates the package through
[`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html).
See the **usethis** vignette [*usethis
setup*](https://usethis.r-lib.org/articles/usethis-setup.html) and
[`help("use_description", package = "usethis")`](https://usethis.r-lib.org/reference/use_description.html)
for details.

[`usethis::create_package()`](https://usethis.r-lib.org/reference/create_package.html)
uses information stored in `.Rprofile` files to fill in default
information. Such files can exist in various locations, for example at
`D:\Userdata\<username>\Documents\.Rprofile`: use
[`usethis::edit_r_profile()`](https://usethis.r-lib.org/reference/edit.html)
to open the `.Rprofile` file that **usethis** finds, see
[`help("Startup")`](https://rdrr.io/r/base/Startup.html) for details.

``` r

path_to_package <- file.path(getwd(), pkgname)
path_to_package
usethis::create_package(path = path_to_package)
desc::desc() # show contents of the DESCRIPTION file
```

Do:

- Update the `Title` field of the DESCRIPTION file
- Update the `Description` field of the DESCRIPTION file
- Check if the automatically filled in information is correct

## Add package-wide documentation

### License

A license file makes clear what use of your package is allowed.
Overviews of licenses are available at various websites:

- [Blue oak council](https://blueoakcouncil.org/list)
- [choosealicense](https://choosealicense.com/appendix/)
- [CreativeCommons](https://creativecommons.org/chooser/)
- [ELRA License Wizard](http://wizard.elda.org/)
- [GNU.org](https://www.gnu.org/licenses/license-list.html)
- [Licensing
  Assistant](https://interoperable-europe.ec.europa.eu/collection/eupl/solution/licensing-assistant)
- [Open Source Initiative](https://opensource.org/licenses)
- [SPDX license list](https://spdx.org/licenses/)
- [System Package Data Exchange](https://spdx.org/licenses/)
- [tl;drLegal](https://www.tldrlegal.com/browse)

Some legal details are provided at [The Legal Side of Open
Source](https://opensource.guide/legal/).

[CRAN](https://cran.r-project.org/) only
[allows](https://cran.r-project.org/web/packages/policies.html#Source-packages)
packages with licences from [this
list](https://svn.r-project.org/R/trunk/share/licenses/license.db). See
the section ‘Licences’ in
[`help("library")`](https://rdrr.io/r/base/library.html) on how to
notify users that a package uses a license that is not-known-to-be-Free
or Open Source Software.

**usethis** provides utility functions to add licenses (see
`help("licenses", package = "usethis")`. For example, to add a [MIT
license](https://choosealicense.com/licenses/mit/):

``` r

usethis::use_mit_license()
```

### Citation

A citation file makes clear how your package should be cited. See the
documentation in the R package
[**cffr**](https://CRAN.R-project.org/package=cffr) and the GitHub page
[`Citation file format`](https://citation-file-format.github.io/) for
details on the ‘Citation File Format’ used here, and
[`help("citation", package = "utils")`](https://rdrr.io/r/utils/citation.html)
on the base R citation style.

``` r

cffr::cff_write(dependencies = FALSE)
```

### README

``` r

usethis::use_readme_rmd()
```

Do:

- Manually update `README.Rmd`
  - Add a badge with the version number by including the following code
    in the `README.Rmd` file (the badge does **not** work if the GitHub
    repository is private):  
    `![](https://img.shields.io/github/r-package/v/<repository>/<pkg>?color=blue)`
  - See the file
    [`README_template.Rmd`](https://github.com/JesseAlderliesten/develcoder/blob/main/inst/templates/README_template.Rmd)
    in the folder `inst/templates` for pointers on useful content.
  - `Knit` the `README.Rmd` file to produce a `README.md` file.

#### Troubleshooting

The **usethis** practice of using
[`devtools::build_readme()`](https://devtools.r-lib.org/reference/build_readme.html)
to update `README.md` requires that `README.Rmd` and `README.md` are
staged at the same time. To remove this requirement, delete the hidden
file `.git/hooks/pre-commit` from the R project folder, see the section
‘Description’ in
[`help("use_readme_rmd", package = "usethis")`](https://usethis.r-lib.org/reference/use_readme_rmd.html)
for details.

### Package overview

A package overview through the file `R/<pkg>-package.R` makes that, if
package `<pkg>` has been loaded (i.e., `library(<pkg>)` has been run),
`help("<pkg>")` produces a relevant description of the package with
links to [GitHub](https://github.com/) and to the package website. It is
also used by **usethis** to list imported functions, and can be
configured to give an overview of the functions in the package.

``` r

usethis::use_package_doc() # Create R/<pkg>-package.R
```

### NEWS

``` r

usethis::use_news_md() # Create NEWS.md
```

## Set up testing infrastructure

It is convenient to have a collection of tests for your functions (see
section [Add
tests](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html#add-tests)
in vignette *Package development* for background. Various packages can
be used to create and run such tests, see section [Packages
tests](https://cran.r-project.org/view=PackageDevelopment#packages-tests)
from the CRAN Task View `Package Development and Maintenance` for an
overview. To use package
[**tinytest**](https://CRAN.R-project.org/package=tinytest) for testing,
set up its infrastructure through:

``` r

tinytest::setup_tinytest(pkgdir = ".")
devtools::document()
```

To use package
[**testthat**](https://cran.r-project.org/package=testthat) for testing,
set up its infrastructure through:

``` r

usethis::use_test("<func>")
devtools::document()
```

## Set up a GitHub repository

For more information about setting up and using GitHub and Git, see the
vignette *Using Git and GitHub* from package **checkrpkgs**:
[`utils::vignette("git_github", package = "checkrpkgs")`](https://jessealderliesten.github.io/checkrpkgs/articles/git_github.html).

``` r

usethis::use_git(message = "Initial commit")
# Notes:
# - If you get the error message 'You are not the current owner of the
#   GitHub repository', restart R as administrator and try again.
# - You might need to refresh the browser after the GitHub repository is created.
usethis::use_github(private = TRUE)
usethis::git_vaccinate()
```

The code below can be used to change the name of the default branch of
the current repository from `master` to `main`, see the [blogpost from
Posit](https://tidyverse.org/blog/2021/10/renaming-default-branch/) for
details.

``` r

usethis::git_default_branch() # show default branch for the current repository
usethis::git_default_branch_rename(from = "master", to = "main")
# Sometimes this takes a while before it works
usethis::git_default_branch_rediscover()
```

## Automate checks

[`GitHub Actions`](https://docs.github.com/en/actions) (`GHA`) is a
continuous integration service to automatically run code upon certain
triggers. These triggers are defined in `workflows`, see the
[reference](https://docs.github.com/en/actions/reference/workflows-and-actions)
and the
[How-to](https://docs.github.com/en/actions/how-tos/manage-workflow-runs).
The workflow
[`check-standard.yaml`](https://github.com/r-lib/actions/blob/v2-branch/examples/check-standard.yaml)
from [`r-lib`](https://github.com/r-lib) runs
[`R CMD check`](https://r-pkgs.org/R-CMD-check.html) for the latest
version of R on Linux, MacOS and Windows, as well as the previous and
development version of R on Linux. The workflow
[`check-no-suggests.yaml`](https://github.com/r-lib/actions/blob/v2-branch/examples/check-no-suggests.yaml)
checks that the code passes
[`R CMD check`](https://r-pkgs.org/R-CMD-check.html) even if
dependencies in `Suggests` are not installed.

``` r

usethis::use_github_action("check-standard")
usethis::use_github_action("check-no-suggests")
```

After setting up these workflows, adjust the created `.yaml` files
(i.e., `<pkg>\.github\workflows\check-standard.yaml` and
`<pkg>\.github\workflows\check-no-suggests.yaml`) to include some other
useful triggers for `GitHub Actions` (see the template files
`check-standard.yaml` and `check-no-suggests.yaml` in folder `templates`
in the local package folder or in
[inst/templates](https://github.com/JesseAlderliesten/develcoder/tree/main/inst/templates)
on the GitHub repository):

- you made changes, or someone else proposed changes to code in the
  current repository:  
  add `pull_request:` to section `on:` to run `GitHub Actions` on pull
  requests. You can remove `push` from section `on:`: it should be
  sufficient to run `R CMD check` locally before pushing and run
  `GitHub Actions` on pull requests.
- you made changes to a repository and want to check if a reverse
  dependency (i.e., a package that depends on the package you changed)
  is still working fine:  
  add `workflow_dispatch:` to section `on:` in the `.yaml` file of the
  reverse dependency to be able to manually trigger `GitHub Actions`.
  See section [Use GitHub
  Actions](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html#use-github-actions)
  in the vignette *Package development* how to use it:
  [`utils::vignette("pkg_devel", package = "develcoder")`](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.md).
- someone else made changes to packages your package depends on:  
  add `schedule: - cron: "23 4 * * 6"` to section `on:` to run every
  Saturday on 04:23 UTC. The [cron
  specification](https://en.wikipedia.org/wiki/Cron) consists of five
  elements that indicate the minute (0 - 59), hour (0 - 23), day of the
  month (1 - 31), month (1 - 12), and day of the week (0 - 6). This
  timing is approximate and the actual time the check is run depends on
  how busy the servers are.
- If the package declares a dependency on a minimum R version in its
  DESCRIPTION file, it is useful to specify that minimum declared R
  version to run in addition to the default ones used in the template:
  for example,  
  add `- {os: ubuntu-latest, r: '4.1.0'}` to section `matrix: config:`
  to also run the workflow with R version 4.1.0 if your package declares
  R 4.1.0 as minimum version.

For further documentation, see the section [GHA: documentation and
help](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html#gha-documentation-and-help)
in the vignette *Package development*:
[`utils::vignette("pkg_devel", package = "develcoder")`](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.md).

## Set up a package website

Package websites make it possible for people to look at your package
without installing it. The package website also automatically creates
[hyperlinked cross-references](https://r-pkgs.org/vignettes.html#links)
to functions and documentation you refer to.

To set up a package website, you can use
[`usethis::use_pkgdown()`](https://usethis.r-lib.org/reference/use_pkgdown.html),
see the documentation about package
[**pkgdown**](https://pkgdown.r-lib.org/) and the chapter
[Website](https://r-pkgs.org/website.html) from the `R packages` book
for further details.

To also set up a [GitHub action](#automate-checks) to automatically
build and update the package website if you push changes to your package
to GitHub (defined in the file `<pkg>\.github\workflows\pkgdown.yaml`),
run the following code:

``` r

# calls usethis::use_pkgdown() and creates '<pkg>\.github\workflows\pkgdown.yaml'
usethis::use_pkgdown_github_pages()
devtools::document() # To update package-wide documentation
```

After a few minutes, the website should be present. The URL has the
structure `https://<username>.github.io/<repository>/`, e.g.,
[`https://jessealderliesten.github.io/develcoder/`](https://jessealderliesten.github.io/develcoder/).

Refer from the README to the pkgdown website.

To add a light-switch to the pkgdown-website, add the line  
`light-switch: true` below the `template` heading in the `_pkgdown.YML`
file, see the
[documentation](https://pkgdown.r-lib.org/articles/customise.html#light-switch)
and the [example
code](https://github.com/JesseAlderliesten/develcoder/blob/main/_pkgdown.yml)
for this repository. The `_pkgdown.YML` file is located in the top-level
package folder or in folder `pkgdown` and can also have extension
`.YAML`; it is **not** the file `<pkg>\.github\workflows\pkgdown.yaml`
that defines the [GitHub Action](#automate-checks) to automatically
build and update the package website if you push changes to your package
to GitHub.

## Documentation and further development

Further package development is described in the vignette *Package
development*:
[`utils::vignette("pkg_devel", package = "develcoder")`](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html).
Section [Documentation and
help](https://jessealderliesten.github.io/develcoder/articles/pkg_devel.html#documentation-and-help)
from that vignette contains further references.
