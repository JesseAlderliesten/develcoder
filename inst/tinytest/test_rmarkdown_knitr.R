#### base ####
expect_true(all(
  c("mean", "sum", "writeLines") %in%
    ls(getNamespace("base"), all.names = TRUE)
))

#### knitr ####
if(requireNamespace("knitr", quietly = TRUE)) {
  expect_true(
    "knit" %in%
      ls(getNamespace("knitr"), all.names = TRUE)
  )

  expect_true(all(
    c("...", "documentation") %in%
      names(formals(knitr::purl))
  ))

  expect_true(
    "R" %in%
      names(knitr::knit_engines$get())
  )

  expect_true(all(
    c("get", "set") %in%
      names(knitr::opts_chunk)
  ))
  expect_true(all(
    c("echo", "error", "eval", "include") %in%
      names(knitr::opts_chunk$get())
  ))

  expect_true(all(
    c("get", "set") %in%
      names(knitr::opts_knit)))
  expect_true(
    "root.dir" %in%
      names(knitr::opts_knit$get())
  )
}

#### rmarkdown ####
if(requireNamespace("rmarkdown", quietly = TRUE)) {
  expect_true(all(
    c("input", "output_dir", "output_file", "output_format") %in%
      names(formals(rmarkdown::render))
  ))
}

#### tinytex ####
if(requireNamespace("tinytex", quietly = TRUE)) {
  expect_true(
    "pdflatex" %in%
      ls(getNamespace("tinytex"), all.names = TRUE)
  )
}

#### utils ####
expect_true(
  "sessionInfo" %in%
    ls(getNamespace("utils"), all.names = TRUE)
)
