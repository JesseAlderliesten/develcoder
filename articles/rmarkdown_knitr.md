# R Markdown and knitr

### Introduction

This vignette contains information about using
[`R Markdown`](https://pkgs.rstudio.com/rmarkdown/) and
[`knitr`](https://yihui.org/knitr/).

An R Markdown file (`.Rmd`) is a plain-text file with R code and markup.
The markup is written in
[markdown](https://daringfireball.net/projects/markdown/). The R package
[`rmarkdown`](https://cran.r-project.org/package=rmarkdown) converts R
Markdown files to an output file containing the R code, output of the R
code, and additional text.

- Converting an R Markdown file to an HTML file requires either
  [`Pandoc`](https://pandoc.org/) or
  [RStudio](https://posit.co/products/open-source/rstudio) that already
  includes `Pandoc`.

- Converting an R Markdown file to a PDF file requires a
  [`LaTeX`](https://www.latex-project.org/get/) distribution, see the
  `R markdown cookbook` and the `Definitive guide` (both mentioned at
  [Documentation and help](#documentation-and-help)) for extensive help.
  Two common choices are `MiKTex` and `TinyTeX`:

  - [`MiKTex`](https://miktex.org/): when installing `MiKTex`, set
    `install for all users` and
    `always install missing packages on the fly` for all users, see
    [this Stack Exchange
    post](https://tex.stackexchange.com/questions/27138/).
  - [`TinyTeX`](https://yihui.org/tinytex/): use the following code to
    set it up and see [here](https://yihui.org/tinytex/r/) for details:

``` r

writeLines(c(
  '\\documentclass{article}',
  '\\begin{document}', 'Hello world!', '\\end{document}'
), 'test.tex')
tinytex::pdflatex('test.tex')
options(tinytex.verbose = FALSE)
```

### Global Settings for knitr used by R Markdown

For a list of available options, see `str(knitr::opts_chunk$get())` and
the overviews of [options](https://yihui.org/knitr/options/) and
[objects storing options](https://yihui.org/knitr/objects/) at the
package website.

The option `echo = FALSE` hides code from the output. Use numeric values
to include the code of particular chunks. To collect all code as an the
appendix at the end of of a document, see the section
[`Put together all code in the appendix`](https://pkg.yihui.org/rmarkdown-cookbook/code-appendix)
from the `rmarkdown cookbook`.

If the option `include = FALSE` is used, code and results are **not**
included in the output but code **is** executed such that its results
can be used in other code chunks, which is useful as option for
particular chunks, not as global option.

If the option `error = TRUE` is used, code execution will **not** stop
on error (unless `include = FALSE`), but instead the error message is
included in the output. This is useful for non-interactive use in
production settings. If the option `error = FALSE` is used, code
execution stops on error, which makes more sense in interactive use
during development of the script.

### Loading files

Files that have to be used by the `R Markdown` script (e.g., `R` scripts
that are sourced, data files that are read) should be placed in the same
directory as the `R Markdown` file, because by default the working
directory when evaluating `R` code chunks is the directory of the input
document. The working directory can be changed using
`opts_knit$set(root.dir = ...)` but should **not** be changed using
[`setwd()`](https://rdrr.io/r/base/getwd.html), see the `Note` in
[`help("knit", package = "knitr")`](https://rdrr.io/pkg/knitr/man/knit.html).

### Knitting documents to HTML and PDF

The following lines can be used to `Knit` documents (i.e., generate
output in HTML or PDF files containing the script with its output and
additional text) containing a file name including a time-stamp. Using
this way of creating documents creates and keeps local R objects in the
current environment. Although that is useful for inspection and
debugging, the potential use of local objects can lead to
non-reproducibility issues, such that the environment should be cleared
before using it and final files should be created by knitting (e.g.,
using the `Knit` button in `RStudio`), **not** by using
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
(see [here](https://pkg.yihui.org/rmarkdown-book/compile.html#fnref2)).

``` r

DateTimeStamp <- format(Sys.time(), format = "%Y_%m_%d_%H_%M")
rmarkdown::render("FilenameRMarkdownFile.Rmd", output_format = "html_document",
                  output_file = paste0("Filename", DateTimeStamp, ".html"),
                  output_dir = "./knitteddocs")
rmarkdown::render("FilenameRMarkdownFile.Rmd", output_format = "pdf_document",
                  output_file = paste0("Filename", DateTimeStamp, ".pdf"),
                  output_dir = "./knitteddocs")
```

### Adding and collecting code chuncks

Add a new chunk by either using the `Code` \> `Insert Chunk` button or
typing the delimiters ```` ```{r} ```` above and ```` ``` ```` below the
code chunk.

To collect all chunks from a R Markdown document that contain R code
into a conventional R script use
`knitr::purl("<filename>.Rmd", documentation = 0)`. However, the various
R Markdown options will **not** be incorporated in such an R script,
which might hamper exactly reproducing the analyses as executed when
running the R Markdown file, see the note in
[`help("purl", package = "knitr")`](https://rdrr.io/pkg/knitr/man/knit.html).

### Formatting in R Markdown

#### Section headings and linking

Section headings can be created by putting a number sign (`#`) before
the heading text, with additional number signs creating sub-headings.

Links to another section in the same document can be created by putting
the section heading in square brackets: `[<Section title>]`. To show an
alternative text in the link, put the alternative text in square
brackets before the section heading: `[<link text>][<Section title>]`.
To link to URLs, put the link text in square brackets followed by the
URL in round brackets: `[<link text>](<vignette_filename>.html)`. If
sections on the website are proper headings, you can refer to them by
adding a hash followed by the heading, with spaces replaced by dashes
(`-`).

    This is a link to this section: [Formatting in R Markdown]. This is another link
    to the same section, with alternative text as link:
    [The same section][Formatting in R Markdown]. And a link to the same section in
    [the online version of this vignette](https://jessealderliesten.github.io/develcoder/articles/rmarkdown_knitr.html#formatting-in-r-markdown).

renders as:

This is a link to this section: [Formatting in R
Markdown](#formatting-in-r-markdown). This is another link to the same
section, with alternative text as link: [The same
section](#formatting-in-r-markdown). And a link to the same section in
[the online version of this
vignette](https://jessealderliesten.github.io/develcoder/articles/rmarkdown_knitr.html#formatting-in-r-markdown).

#### Italic, bold, strike through

    *italic words*, _other italic words_, **bold words**, the combination of
    _An **italic and bold phrase** in italic text_ and ~~strike through~~ all
    emphasise part of a text

is rendered as:

*italic words*, *other italic words*, **bold words**, the combination of
*An **italic and bold phrase** in italic text* and ~~strike through~~
all emphasise part of a text

Partially bold text inside [link text](#section-headings-and-linking)
requires R version 4.1.1 or later.

#### Code chunks

R code chunks can be shown with or without its output through argument
`eval` (which is `TRUE` by default):

```` r
```{r code-chunk-example}
sum(c(1, 2))
mean(c(1, 2))
```
````

shows a code chunk with its output, like:

``` r

sum(c(1, 2))
```

    ## [1] 3

``` r

mean(c(1, 2))
```

    ## [1] 1.5

Whereas

```` r
```{r code-chunk-example-no-output, eval = FALSE}
sum(c(1, 2))
mean(c(1, 2))
```
````

shows a code chunk without its output, like:

``` r

sum(c(1, 2))
mean(c(1, 2))
```

#### Table

    | Name       | Description                      |
    | :--------- | :--------------------------------|
    | `Name one` | Some description                 |
    | `Name two` | Some description                 |

gives:

| Name       | Description      |
|:-----------|:-----------------|
| `Name one` | Some description |
| `Name two` | Some description |

#### Lists

Lists need an empty line before the first item to be correctly rendered.
Sub-items are created by indenting them. Numbered lists (ordered lists)
are created by using a number followed by a dot (`1.`). Non-numbered
lists (non-ordered lists) are created by using asterisks (`*`), plus
signs (`+`), or dashes (`-`).

    non-numbered list:

    * item one
    * item two
      * sub-item one
      * sub-item two

    numbered list:

    1. item one
    2. item two

These lists are rendered as:

non-numbered list:

- item one
- item two
  - sub-item one
  - sub-item two

numbered list:

1.  item one
2.  item two

#### Escaping

To include symbols that indicate markup as literal symbols, escape the
starting markup symbols with a backslash:
`\*\*this is bold if not escaped**` renders as \*\*this is bold if not
escaped\*\* , whereas `**this is bold if not escaped**` renders as the
bold **this is bold if not escaped**.

To include `` (`) `` in the **output**, escape them by enclosing with an
additional delimiters:  
for example, ``` `` `some text` `` ``` produces `` `some text` ``, and
```` ``` `` `some text` `` ``` ```` produces ``` `` `some text` `` ```.
Do **not** start a line of code with a delimiter if you want to escape
other delimiters: that would be interpreted as starting a code section.

To include code to **create** code chunks (i.e., include code which
escapes chunk headings), use

    r ''````{r use-sum}
    1 + 2
    ```

to show how to create a code chunk like

``` r

1 + 2
```

    ## [1] 3

#### Miscellaneous

Newlines can be forced using `\cr` or by ending a line with two spaces
followed by a newline.

Qoutes can be formatting by putting `>` in front of a line.

For an overview of mathematical notation see
<https://rpruim.github.io/s341/S19/from-class/MathinRmd.html>

## Documentation and help

### Books and chapters

- the [`R markdown cookbook`](https://pkg.yihui.org/rmarkdown-cookbook/)
  by Xie, Dervieux, and Riederer
- the [`Definitive guide`](https://pkg.yihui.org/rmarkdown-book/) by
  Xie, Allaire, and Grolemund
- the book [`RMarkdown for Scientists`](https://rmd4sci.njtierney.com/)
  by Tierney
- Chapters
  [`Reports with R Markdown`](https://epirhandbook.com/en/new_pages/rmarkdown.html)
  and
  [`Organizing routine reports`](https://epirhandbook.com/en/new_pages/reportfactory.html)
  from `The Epidemiologist R Handbook`

### Websites

- the package website for [`knitr`](https://yihui.org/knitr/)
- the [`Markdown guide`](https://www.markdownguide.org/), with a section
  on [basic syntax](https://www.markdownguide.org/basic-syntax/)
- a [website](https://rmarkdown.rstudio.com/) on R Markdown from
  [Posit](https://posit.co/)

### Miscellaneous

- a
  [`cheatsheet`](https://opensource.posit.co/resources/cheatsheets/rmarkdown/)

## sessionInfo

    ## R version 4.6.1 (2026-06-24)
    ## Platform: x86_64-pc-linux-gnu
    ## Running under: Ubuntu 24.04.5 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
    ## LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
    ##  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
    ##  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
    ## [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
    ## 
    ## time zone: UTC
    ## tzcode source: system (glibc)
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] digest_0.6.39     desc_1.4.3        R6_2.6.1          fastmap_1.2.0    
    ##  [5] xfun_0.62         cachem_1.1.0      knitr_1.52        htmltools_0.5.9  
    ##  [9] rmarkdown_2.32    lifecycle_1.0.5   cli_3.6.6         sass_0.4.10      
    ## [13] pkgdown_2.2.1     textshaping_1.0.5 jquerylib_0.1.4   systemfonts_1.3.2
    ## [17] compiler_4.6.1    tools_4.6.1       ragg_1.5.2        bslib_0.12.0     
    ## [21] evaluate_1.0.5    yaml_2.3.12       otel_0.2.0        jsonlite_2.0.0   
    ## [25] rlang_1.3.0       fs_2.1.0          htmlwidgets_1.6.4
