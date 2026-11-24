#### Preparations ####

##### Create objects to use in tests #####
error_base <- "Do not list package 'base' as dependency in the DESCRIPTION file"
error_pkg_types <- paste0("Each package should be listed in only one of the",
                          " types of\ndependencies. The following packages are",
                          " listed in multiple types:\n")
error_R_early <- paste0("The DESCRIPTION file lists a declared minimum version",
                        " of 'R' that\nis earlier than declared minimum",
                        " versions of base or recommended packages:\n")
error_R_type <- paste0("Dependency 'R' should be in field 'Depends' of the",
                       " DESCRIPTION file, not in field")
error_R_version <- paste0("Indicate a minimum version number for 'R' if you",
                          " list it in the\nDESCRIPTION file, e.g., 'R (>=",
                          " 4.6)'. Currently listed are version:\n")
warn_pkg_version <- paste0("Base or recommended packages in the DESCRIPTION",
                           "\nfile declare different minimum versions:\n")
warn_R_patch <- paste0("It is good practice to only use '0' as patch level for",
                       " dependencies\non R. You might want to adjust the",
                       " following versions:\n")

df_empty <- data.frame(type = character(0), package = character(0),
                       version = character(0))
df_R <- data.frame(type = "Depends", package = "R", version = ">= 4.0.0")
df_R_late <- df_R
df_R_late[, "version"] <- ">= 4.1.0"
df_R_late_patch <- df_R_late
df_R_late_patch[, "version"] <- "<= 4.1.1"
df_R_patch <- df_R
df_R_patch[, "version"] <- ">= 4.0.1"
df_utils_nonversioned <- data.frame(type = "Depends", package = "utils",
                                    version = "*")
df_utils_versioned <- df_utils_nonversioned
df_utils_versioned[, "version"] <- ">= 4.0.0"
df_utils_versioned_early <- df_utils_nonversioned
df_utils_versioned_early[, "version"] <- ">= 3.6.0"
df_tools_nonversioned <- data.frame(type = "Depends", package = "tools",
                                    version = "*")
df_tools_versioned <- df_tools_nonversioned
df_tools_versioned[, "version"] <- ">= 4.0.0"
df_tools_versioned_late <- df_tools_versioned
df_tools_versioned_late[, "version"] <- ">= 4.1.0"

##### Create a temporary directory and set the working directory to it #####
my_tempdir <- progutils::create_tempdir(prefix = "check_base_deps")
path_desc <- fs::path(my_tempdir, "DESCRIPTION")
withr::local_dir(new = my_tempdir)

#### Tests ####
##### No DESCRIPTION file present #####
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = "Incorrect 'path'? No DESCRIPTION file found at", fixed = TRUE)

##### No dependencies #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  df_empty
))

##### a single non-recommended dependency #####
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  df_empty
))

##### multiple non-recommended dependencies #####
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- suppressWarnings(
  desc::desc_set_dep("progutils", type = "Imports", version = "1.2.0",
                     file = path_desc))
desc <- suppressWarnings(
  desc::desc_set_dep("checkrpkgs", type = "Depends", version = "1.3.1",
                     file = path_desc))
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  df_empty
))

##### non-recommended dependency as multiple types #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("progutils", type = "Imports", file = path_desc)
desc <- suppressWarnings(
  desc::desc_set_dep("progutils", type = "Depends", file = path_desc))
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = paste0(error_pkg_types, "progutils = Imports, Depends"),
  fixed = TRUE)

##### multiple non-recommended dependencies as multiple types #####
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- suppressWarnings(
  desc::desc_set_dep("checkinput", type = "Enhances", file = path_desc))
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = paste0(error_pkg_types,
                   "checkinput = Imports, Enhances; progutils = Imports, Depends"),
  fixed = TRUE)

##### base in Imports, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep("base", type = "Imports", file = path_desc)
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = error_base, fixed = TRUE)

##### base in Suggests, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep("base", type = "Suggests", file = path_desc)
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = error_base, fixed = TRUE)

##### base in Depends, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep("base", type = "Depends", file = path_desc)
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = error_base, fixed = TRUE)

##### base in Depends, versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep(
  "base", type = "Depends", version = ">= 4.0.0", file = path_desc)
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = error_base, fixed = TRUE)

##### R in Imports, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- suppressWarnings(
  desc::desc_set_dep("R", type = "Imports", file = path_desc))
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = paste0(error_R_type, " 'Imports'"), fixed = TRUE)

##### R in Suggests, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- suppressWarnings(
  desc::desc_set_dep("R", type = "Suggests", file = path_desc))
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = paste0(error_R_type, " 'Suggests'"), fixed = TRUE)

##### R in Depends, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep("R", type = "Depends", file = path_desc)
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = paste0(error_R_version, "'*'"), fixed = TRUE)

##### R Depends, versioned, patchlevel nonzero #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep(
  "R", type = "Depends", version = ">= 4.0.1", file = path_desc)
expect_warning(
  expect_identical(
    check_base_deps(path = my_tempdir),
    df_R_patch
  ), pattern = paste0(warn_R_patch, ">= 4.0.1"), strict = TRUE, fixed = TRUE)

##### R Depends, versioned, patchlevel zero #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep(
  "R", type = "Depends", version = ">= 4.0.0", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  df_R
))

##### R occurs twice to indicate a range #####
# Need 'desc_set_deps()' instead of 'desc_set_dep()' to add the same dependency
# twice as the same type instead of overwrite the first occurrence.
desc <- desc::desc_set_deps(
  rbind(df_R,
        df_tools_versioned,
        data.frame(type = "Depends", package = "R", version = "<= 5.0.0")),
  file = path_desc)
expect_warning(
  expect_identical(
    check_base_deps(path = my_tempdir),
    rbind(df_R, df_tools_versioned,
          data.frame(type = "Depends", package = "R", version = "<= 5.0.0"))
  ), pattern = paste0("Dependency 'R' occurs 2 times in the DESCRIPTION file,",
                      " with versions:\n'>= 4.0.0', '<= 5.0.0'"),
  strict = TRUE, fixed = TRUE)

desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_deps(
  rbind(df_R, df_R_patch, df_R_late_patch), file = path_desc)
expect_warning(
  expect_identical(
    check_base_deps(path = my_tempdir),
    rbind(df_R, df_R_patch, df_R_late_patch)
  ), pattern = paste0("Dependency 'R' occurs 3 times in the DESCRIPTION file,",
                      " with versions:\n'>= 4.0.0', '>= 4.0.1', '<= 4.1.1'"),
  strict = TRUE, fixed = TRUE)
expect_warning(
  expect_identical(
    check_base_deps(path = my_tempdir),
    rbind(df_R, df_R_patch, df_R_late_patch)
  ), pattern = paste0(warn_R_patch, ">= 4.0.1, <= 4.1.1"),
  strict = TRUE, fixed = TRUE)

##### utils and R in Depends, both non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep("utils", type = "Depends", file = path_desc)
desc <- desc::desc_set_dep("R", type = "Depends", file = path_desc)
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = paste0(error_R_version, "'*'"), fixed = TRUE)

##### utils and R in Depends, utils non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep("utils", type = "Depends", file = path_desc)
desc <- desc::desc_set_dep(
  "R", type = "Depends", version = ">= 4.0.0", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_R, df_utils_nonversioned)
))

##### utils and R in Depends, R non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep(
  "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep("R", type = "Depends", file = path_desc)
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = paste0(error_R_version, "'*'"), fixed = TRUE)

##### utils and R, same version #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep(
  "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  "R", type = "Depends", version = ">= 4.0.0", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_R, df_utils_versioned)
))

##### utils and R, R earlier version #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep(
  "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  "R", type = "Depends", version = ">= 3.6.0", file = path_desc)
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = paste0(error_R_early, "R >= 3.6.0 with utils: >= 4.0.0"), fixed = TRUE)

##### utils and R, R later version #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep(
  "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  "R", type = "Depends", version = ">= 4.1.0", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_R_late, df_utils_versioned)
))

##### multiple recommended, non-versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep("utils", type = "Depends", file = path_desc)
desc <- desc::desc_set_dep("tools", type = "Depends", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_tools_nonversioned, df_utils_nonversioned)
))

##### multiple recommended, one versioned #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep(
  "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep("tools", type = "Depends", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_tools_nonversioned, df_utils_versioned)
))

##### multiple recommended, same version #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep(
  "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  "tools", type = "Depends", version = ">= 4.0.0", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_tools_versioned, df_utils_versioned)
))

##### multiple recommended, different version #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep(
  "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  "tools", type = "Depends", version = ">= 4.1.0", file = path_desc)
expect_warning(
  expect_identical(
    check_base_deps(path = my_tempdir),
    rbind(df_tools_versioned_late, df_utils_versioned)),
  pattern = paste0(warn_pkg_version, "tools: >= 4.1.0; utils: >= 4.0.0"),
  strict = TRUE, fixed = TRUE
)

##### multiple recommended, same version that are earlier than R #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep(
  "R", type = "Depends", version = ">= 4.1.0", file = path_desc)
desc <- desc::desc_set_dep(
  "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  "tools", type = "Depends", version = ">= 4.0.0", file = path_desc)
expect_silent(expect_identical(
  check_base_deps(path = my_tempdir),
  rbind(df_R_late, df_tools_versioned, df_utils_versioned)
))

##### multiple recommended, same version that are later than both R versions #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_deps(
  rbind(data.frame(package = "checkinput", type = "Imports", version = "*"),
        df_R,
        data.frame(package = "utils", type = "Depends", version = ">= 4.1.0"),
        df_tools_versioned_late,
        data.frame(type = "Depends", package = "R", version = "<= 4.1.0")),
  file = path_desc)
expect_warning(
  expect_error(
    check_base_deps(path = my_tempdir),
    pattern = paste0(error_R_early,
                     "R >= 4.0.0, <= 4.1.0 with utils: >= 4.1.0; tools: >= 4.1.0"),
    fixed = TRUE),
  pattern = paste0("Dependency 'R' occurs 2 times in the DESCRIPTION file,",
                   " with versions:\n'>= 4.0.0', '<= 4.1.0'"),
  strict = TRUE, fixed = TRUE)

##### multiple recommended, different versions, some later than R #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep(
  "R", type = "Depends", version = ">= 3.6.0", file = path_desc)
desc <- desc::desc_set_dep(
  "utils", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- desc::desc_set_dep(
  "stats", type = "Depends", file = path_desc)
desc <- desc::desc_set_dep(
  "tools", type = "Depends", version = ">= 4.1.0", file = path_desc)
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = paste0(error_R_early, "R >= 3.6.0 with tools: >= 4.1.0; utils: >= 4.0.0"),
  fixed = TRUE)

##### multiple recommended, different versions, all earlier than R #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("checkinput", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep(
  "R", type = "Depends", version = ">= 4.1.0", file = path_desc)
desc <- desc::desc_set_dep(
  "utils", type = "Depends", version = ">= 3.6.0", file = path_desc)
desc <- desc::desc_set_dep(
  "stats", type = "Depends", file = path_desc)
desc <- desc::desc_set_dep(
  "tools", type = "Depends", version = ">= 4.0.0", file = path_desc)
desc <- suppressWarnings(
  desc::desc_set_dep(
    "stats", type = "Depends", version = ">= 4", file = path_desc))
expect_warning(
  expect_identical(
    check_base_deps(path = my_tempdir),
    rbind(df_R_late,
          data.frame(type = "Depends", package = "stats", version = ">= 4"),
          df_tools_versioned, df_utils_versioned_early)),
  pattern = paste0(warn_pkg_version,
                   "stats: >= 4; tools: >= 4.0.0; utils: >= 3.6.0"),
  strict = TRUE, fixed = TRUE)

##### utils in two different types #####
desc <- desc::description$new("!new")
desc$write(file = path_desc)
desc <- desc::desc_set_dep("utils", type = "Imports", file = path_desc)
desc <- desc::desc_set_dep("utils", type = "Depends", file = path_desc)
expect_error(
  check_base_deps(path = my_tempdir),
  pattern = error_pkg_types, fixed = TRUE)

#### Remove objects used in tests ####
unlink(my_tempdir, recursive = TRUE)
rm(desc, df_empty, df_R, df_R_late, df_R_late_patch, df_R_patch,
   df_tools_nonversioned, df_tools_versioned, df_tools_versioned_late,
   df_utils_nonversioned, df_utils_versioned, df_utils_versioned_early,
   error_base, error_pkg_types, error_R_early, error_R_type, error_R_version,
   my_tempdir, path_desc, warn_pkg_version, warn_R_patch)
