#### Preparations ####

##### Create objects to use in tests #####
warn_R_versioned <- "Indicate a minimum version number for 'R'"
warn_R_type <- "Dependency 'R' should be in field 'Depends' of the DESCRIPTION file, not in field"
warn_base <- "Do not list 'base' as dependency in the DESCRIPTION file"
warn_recommended <- paste0("The DESCRIPTION file lists base or recommended",
                           " packages with different declared minimum versions")
warn_recommended_R <- paste0("The DESCRIPTION file lists base or recommended packages",
                             " with minimum\nversions that differ from the declared",
                             " minimum version of 'R'")

df_checkinput <- data.frame(type = "Imports", package = "checkinput", version = "*")
df_R <- data.frame(type = "Depends", package = "R", version = ">= 4.0.0")
df_R_early <- df_R
df_R_early[, "version"] <- ">= 3.6.0"
df_R_late <- df_R
df_R_late[, "version"] <- ">= 4.1.0"
df_utils_nonversioned <- data.frame(type = "Depends", package = "utils", version = "*")
df_utils_versioned <- df_utils_nonversioned
df_utils_versioned[, "version"] <- ">= 4.0.0"
df_tools_nonversioned <- data.frame(type = "Depends", package = "tools", version = "*")
df_tools_versioned <- df_tools_nonversioned
df_tools_versioned[, "version"] <- ">= 4.0.0"
df_tools_versioned_late <- df_tools_versioned
df_tools_versioned_late[, "version"] <- ">= 4.1.0"

##### Create a temporary directory and temporarily set the working directory to it #####
my_tempdir <- progutils::create_tempdir(prefix = "check_base_deps")
path_desc <- fs::path(my_tempdir, "DESCRIPTION")
withr::local_dir(new = my_tempdir)

#### Tests ####
##### No DESCRIPTION file present #####
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = "No DESCRIPTION file found", fixed = TRUE)

##### No dependencies #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  data.frame(type = character(0), package = character(0), version = character(0))
))

##### a single non-recommended dependency #####
desc <- desc::desc_set_dep(
  package = "checkinput", type = "Imports", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  df_checkinput
))

##### multiple non-recommended dependencies #####
desc <- desc::desc_set_dep(
  package = "progutils", type = "Imports", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_checkinput,
        data.frame(type = "Imports", package = "progutils", version = "*"))
))

##### base in Imports, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(package = "base", type = "Imports", file = path_desc)
expect_error(check_base_deps(path = my_tempdir), pattern = warn_base, fixed = TRUE)

##### base in Suggests, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(package = "base", type = "Suggests", file = path_desc)
expect_error(check_base_deps(path = my_tempdir), pattern = warn_base, fixed = TRUE)

##### base in Depends, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(package = "base", type = "Depends", file = path_desc)
expect_error(check_base_deps(path = my_tempdir), pattern = warn_base, fixed = TRUE)

##### base in Depends, versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "base", type = "Depends", version = ">= 4.0.0", file = path_desc)
expect_error(check_base_deps(path = my_tempdir), pattern = warn_base, fixed = TRUE)

##### R in Imports, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- suppressWarnings(
  desc::desc_set_dep(package = "R", type = "Imports", file = path_desc))
expect_error(check_base_deps(path = my_tempdir),
             pattern = paste0(warn_R_type, " 'Imports'"), fixed = TRUE)

##### R in Suggests, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- suppressWarnings(
  desc::desc_set_dep(package = "R", type = "Suggests", file = path_desc))
expect_error(check_base_deps(path = my_tempdir),
             pattern = paste0(warn_R_type, " 'Suggests'"), fixed = TRUE)

##### R in Depends, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(package = "R", type = "Depends", file = path_desc)
expect_error(check_base_deps(path = my_tempdir),
             pattern = warn_R_versioned, fixed = TRUE)

##### R Depends, versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "R", type = "Depends", version = ">= 4.0.0", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  df_R
))

##### utils and R in Depends, both non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(package = "utils", type = "Depends", file = path_desc)
desc <- desc::desc_set_dep(package = "R", type = "Depends", file = path_desc)
expect_error(check_base_deps(path = my_tempdir), pattern = warn_R_versioned, fixed = TRUE)

##### utils and R in Depends, utils non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(package = "utils", type = "Depends", file = path_desc)
desc <- desc::desc_set_dep(
  package = "R", type = "Depends", version = ">= 4.0.0", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_R, df_utils_nonversioned)
))

##### utils and R in Depends, R non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(package = "R", type = "Depends", file = path_desc)
expect_error(check_base_deps(path = my_tempdir), pattern = warn_R_versioned, fixed = TRUE)

##### utils and R, same version #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  package = "R", type = "Depends", version = ">= 4.0.0", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_R, df_utils_versioned)
))

##### utils and R, R earlier version #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  package = "R", type = "Depends", version = ">= 3.6.0", file = path_desc)
expect_warning(
  expect_identical(
    check_base_deps(path = my_tempdir),
    rbind(df_R_early, df_utils_versioned)
  ),
  pattern = warn_recommended_R, strict = TRUE, fixed = TRUE)

##### utils and R, R later version #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  package = "R", type = "Depends", version = ">= 4.1.0", file = path_desc)
expect_warning(
  expect_identical(
    check_base_deps(path = my_tempdir),
    rbind(df_R_late, df_utils_versioned)
  ),
  pattern = warn_recommended_R, fixed = TRUE)

##### multiple recommended, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "utils", type = "Depends", file = path_desc)
desc <- desc::desc_set_dep(
  package = "tools", type = "Depends", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_tools_nonversioned, df_utils_nonversioned)
))

##### multiple recommended, one versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  package = "tools", type = "Depends", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_tools_nonversioned, df_utils_versioned)
))

##### multiple recommended, same version #####
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  package = "tools", type = "Depends", version = ">= 4.0.0", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_tools_versioned, df_utils_versioned)
))

##### multiple recommended, different version #####
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  package = "tools", type = "Depends", version = ">= 4.1.0", file = path_desc)
expect_warning(
  expect_identical(
    check_base_deps(path = my_tempdir),
    rbind(df_tools_versioned_late, df_utils_versioned)),
  pattern = warn_recommended, strict = TRUE, fixed = TRUE
)

##### multiple recommended, same version that differs from R #####
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "R", type = "Depends", version = ">= 4.1.0", file = path_desc)
desc <- desc::desc_set_dep(
  package = "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  package = "tools", type = "Depends", version = ">= 4.0.0", file = path_desc)
expect_warning(
  expect_identical(
    check_base_deps(path = my_tempdir),
    rbind(df_R_late, df_tools_versioned, df_utils_versioned)),
  pattern = warn_recommended_R, strict = TRUE, fixed = TRUE)

##### multiple recommended, different versions that differ from R #####
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  package = "R", type = "Depends", version = ">= 3.6.0", file = path_desc)
desc <- desc::desc_set_dep(
  package = "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  package = "tools", type = "Depends", version = ">= 4.1.0", file = path_desc)
expect_warning(
  expect_identical(
    check_base_deps(path = my_tempdir),
    rbind(df_R_early, df_tools_versioned_late, df_utils_versioned)),
  pattern = warn_recommended, strict = TRUE, fixed = TRUE)
expect_warning(
  expect_identical(
    check_base_deps(path = my_tempdir),
    rbind(df_R_early, df_tools_versioned_late, df_utils_versioned)),
  pattern = warn_recommended_R, strict = TRUE, fixed = TRUE)

#### Remove objects used in tests ####
unlink(my_tempdir, recursive = TRUE)
rm(desc, df_checkinput, df_R, df_R_early, df_R_late,
   df_tools_nonversioned, df_tools_versioned, df_tools_versioned_late,
   df_utils_nonversioned, df_utils_versioned, my_tempdir, path_desc, warn_base,
   warn_R_type, warn_R_versioned, warn_recommended, warn_recommended_R)
