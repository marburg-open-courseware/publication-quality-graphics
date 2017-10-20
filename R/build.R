library(bookdown)

if (file.exists("_main.Rmd")) 
  file.remove("_main.Rmd")

# render_book("index.Rmd", "bookdown::gitbook")
render_book("index.Rmd", "bookdown::gitbook", clean = FALSE)
