##### Using temporary files #####
# - Could also use local(...)? See withr::with_tempfile()
#   \dontshow{
#     my_tempdir <- tempdir()
#     example_dir <- file.path(my_tempdir, example_dir)
#   }
#   See also https://stat.ethz.ch/pipermail/r-devel/2018-March/075783.html
# - On the problem of changing relative paths depending on how a check is run,
#   see `testthat::test_path()`.


#### Check tests ####
# Check for which functions no test file has been written.
devtools::document()
files_R <- list.files(file.path(".", "R"))
files_man <- list.files(path = file.path(".", "man"), pattern = "\\.Rd$")
expected_man <- sub(pattern = "\\.Rd$", replacement = ".R", x = files_man)
expected_files <- sort(unique(paste0("test_", c(files_R, expected_man))))
expected_files[!(expected_files %in% list.files("./inst/tinytest"))]

tinytest::test_all()


#### Increment package version ####
# To increment the package version, adjust the package version in the
# DESCRIPTION file, or run R as administrator and then use usethis::use_version().
# In the latter case, do not automatically commit the change, but do so manually
# to adjust the commit message to, e.g., Bump version. Breaking change: <func>
# no longer ... .


#### Preparing for updates ####
# Do:
# - Restyle and publish the NEWS-file at each new package release.
devtools::document()

# Using 'manual = FALSE' because building the manual leads to latex errors.
devtools::check(manual = FALSE, force_suggests = TRUE, run_dont_test = TRUE)

.libPaths() # Check if output of .libPaths() is correct.
devtools::install(quick = FALSE, upgrade = "ask", build_vignettes = TRUE)
devtools::install(quick = FALSE, upgrade = "never", build_vignettes = TRUE)

# Load the package and view the help files as usual outside devtools:
library(basename(getwd()), character.only = TRUE)
?reorder_levels
browseVignettes(package = basename(getwd()))
# If no vignettes are visible, devtools::install() was probably run with the
# default 'build_vignettes = FALSE': change it to use 'build_vignettes = TRUE'.


#### Merging devel-branch with master ####
# To merge the devel-branch with master, go the the devel-branch on GitHub.
# <Contribute> > Open Pull Request.
# Copy the updated 'NEWS' in the 'description' field and use the button 'Create
# pull request'.

# If you see 'No conflicts with base branch: Merging can be performed
# automatically', you can use the green 'Merge pull request' button, or change to
# 'Squash and merge'.

# Otherwise, you will see 'This branch has conflicts that must be resolved':
# follow the instructions to resolve the conflicts. Then push the button 'Commit
# merge'. Then you will see 'No conflicts with base branch' and you can proceed
# as described in the previous paragraph.

# After a successful merge, you will see a message that you can delete the
# devel-branch, which you can do. To do so later, go to 'Pull requests', select
# the 'closed', and scroll down to the button 'Delete branch'.

# In RStudio, open the relevant project to check there are no commits left. Then
# you can move to the 'master' branch and pull to get all updates you just
# committed to the master branch, or first delete the project and pull the fresh
# one.

# Then you can delete the old package versions (see .libPaths()) and install the
# updated versions following your own instructions on the GitHub pages of the
# relevant packages.


#### Setting up new GitHub branch ####
# Then set up a new GitHub branch:
# - At the GitHub page of the package:
#   `Branch` icon > green `New branch` button > use `devel` as branch name >
#   green `Create new branch` button.
# - Go back to the GitHub page of the package, and at the green `Code` button >
#   copy URL to clipboard.
# - In RStudio: `File` > `New project` > `Version control` > `Git` and paste the
#   copied URL in the `Repository URL` > `Create Project`.
# - Then (still in RStudio) in the `Git` menu change from `master` to the
#   `devel`-branch.


#### Troubleshooting ####
# To prevent regex-classes in example code from being interpreted as links,
# which leads to the error '@section Could not resolve link to topic ":blank:"
# in the dependencies or base packages' when running devtools::document(), use
# backticks to format a line as code, or wrap consecutive lines in \code{...}.

#### Guidelines ####
# See https://developer.r-project.org/,
# https://developer.r-project.org/devel-guidelines.txt
