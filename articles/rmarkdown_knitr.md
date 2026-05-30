# R Markdown and knitr

## Introduction

This file contains information about using [R
Markdown](https://pkgs.rstudio.com/rmarkdown/) and
[knitr](https://yihui.org/knitr/).

An R Markdown file is an R script with markup to enable to combine the
script (including the comments) together with its output and additional
text in a single document. The R package
[rmarkdown](https://cran.r-project.org/package=rmarkdown), as well as
either [RStudio](https://www.rstudio.com/) or
[Pandoc](https://pandoc.org/) is required to create an R Markdown file.

To generate a PDF as output, a
[LaTeX](https://www.latex-project.org/get/) distribution needs to be
installed. See the ‘Rmarkdown cookbook’ and the ‘Definitive guide’ (both
mentioned at [Useful sources](#useful-sources) below) for extensive
help.

## Useful sources

- the [R Markdown
  cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/) by Y.
  Xie, C. Dervieux, and E. Riederer
- the [Definitive guide](https://bookdown.org/yihui/rmarkdown/) by Y.
  Xie, J.J. Allaire, and G. Grolemund
- the [Posit](https://posit.co/) website on [R
  Markdown](http://rmarkdown.rstudio.com) and a
  [cheatsheet](https://opensource.posit.co/resources/cheatsheets/rmarkdown/)
- the maintainer’s website on [knitr](https://yihui.org/knitr/)
- the [Markdown guide](https://www.markdownguide.org/)

## Installing

When installing [MikTex](https://miktex.org/) as LaTex distribution, set
`install for all users` and `always install missing packages on the fly`
(for all users), see [this Stack Exchange
post](https://tex.stackexchange.com/questions/27138/how-can-i-fix-the-error-gui-framework-cannot-be-initialized-with-texniccenter)

An alternative to MikText is [TinyTeX](https://yihui.org/tinytex/) (for
debugging see <https://yihui.org/tinytex/r/>):

``` r

writeLines(c(
  '\\documentclass{article}',
  '\\begin{document}', 'Hello world!', '\\end{document}'
), 'test.tex')
tinytex::pdflatex('test.tex')
options(tinytex.verbose = FALSE)
```

## Global Settings for knitr used by R Markdown

For a list of available options, see `str(knitr::opts_chunk$get())` and
details at `https://yihui.org/knitr/options/` and
`https://yihui.org/knitr/objects/`.

The option `echo = FALSE` hides code from the output. Use numeric values
to include the code of particular chunks. To collect all code as an the
appendix at the end of of a document, see
<https://bookdown.org/yihui/rmarkdown-cookbook/code-appendix.html>.

If the option `include = FALSE` is used, code and results are not
included in output, but code *is* executed such that its results can be
used in other code chunks (useful as option for particular chunks, not
as global option).

If the option `error = TRUE` is used, code execution will *not* stop on
error (unless `include = FALSE`), but instead the error message is
included in the output. This is useful in non-interactive use in
production settings. If the option `error = FALSE` is used, code
execution stops on error, which makes more sense in interactive use
during development of the script.

## Loading files

Files that have to be used by the R Markdown script (e.g., R scripts
that are sourced, data files that are read) should be placed in the same
directory as the R Markdown file, because the working directory when
evaluating R code chunks is the directory of the input document by
default. The working directory can be changed using
`opts_knit$set(root.dir = ...)` but should *not* be changed using
[`setwd()`](https://rdrr.io/r/base/getwd.html), see the `Note` in
[`help("knit", package = "knitr")`](https://rdrr.io/pkg/knitr/man/knit.html).

An inferior alternative to including `file = ...` in the header is
including

``` r

source("<path/to/file>.R", local = knitr::knit_global(),
       echo = TRUE, max.deparse.length = 1000)
```

in the body of the chunk. That method has the disadvantages that bare
source code is included in the knitted file without the accompanying
comments, that specification of the environment through the argument
`local` can be
[error-prone](https://bookdown.org/yihui/rmarkdown-cookbook/source-script.html)
and that `max.deparse.length within source(...)` has to be increased to
ensure that all of the source code is printed (see
[`help("source")`](https://rdrr.io/r/base/source.html)).

## Generating documents in HTML and PDF format (‘knitting documents’)

The following lines can be used to knit documents (i.e., generate output
in HTML or PDF files containing the script with its output and
additional text) containing a file name including a time-stamp. Using
this way of creating documents creates and keeps local R objects in the
current environment. Although that can be useful for inspection and
debugging, the potential use of local objects can lead to
non-reproducibility issues, such that the environment should be cleared
before using it and final files should be created by using the `Knit`
button in `RStudio`, *not* by using
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
(see [here](https://bookdown.org/yihui/rmarkdown/compile.html#fnref2)).

``` r

DateTimeStamp <- format(Sys.time(), format = "%Y_%m_%d_%H_%M")
rmarkdown::render("FilenameRMarkdownFile.Rmd", output_format = "html_document",
                  output_file = paste0("Filename", DateTimeStamp, ".html"),
                  output_dir = "./knitteddocs")
rmarkdown::render("FilenameRMarkdownFile.Rmd", output_format = "pdf_document",
                  output_file = paste0("Filename", DateTimeStamp, ".pdf"),
                  output_dir = "./knitteddocs")
```

## Adding and collecting code chuncks

Add a new chunk by either (1) clicking the `Insert Chunk` button on the
toolbar, (2) pressing `Ctrl+Alt+I`, or (3) typing the delimiters
```` ```{r} ```` above and ```` ``` ```` below the code chunk.

To collect all chunks in a R Markdown document that contain R code in a
conventional R script use
`knitr::purl("FilenameRMarkdownFile.Rmd", documentation = 0)`.

Note that the various R Markdown options are not incorporated in such an
R script, which might hamper exactly reproducing the analyses as
executed when running the R Markdown file, see the note in
[`help("purl", package = "knitr")`](https://rdrr.io/pkg/knitr/man/knit.html).

## Formatting in R Markdown

```` formatting
To create lists, an empty line before the is needed:

* unordered list
* item 2
+ sub-item 1
+ sub-item 2

1. ordered list
2. item 2
+ sub-item 1
+ sub-item 2


Making text italic or bold
*italic text* and _italic text_
** bold text **
_Some **bold words** in italic text_

Formatting text as R code:
``` r
<some code here>
```

To not evaluate a code chunk:
```{r, example, eval = FALSE}
<some code here>
```

Bullets for a list:
* Item one
* Item two

Adding a horizontal line:
================

Inserting a table:
| Name       | Description                      |
| :--------- | :--------------------------------|
| `Colname1` | Some description                 |
| `Colname2` | Some description                 |
| `Colname3` | Some description                 |
````
