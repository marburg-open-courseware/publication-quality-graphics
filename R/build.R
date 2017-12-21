# devtools::install_github("fdetsch/Orcs")
library(Orcs)

buildBook(input = "index.Rmd", output_format = "bookdown::gitbook"
          , clean = FALSE, output_dir = "book")
