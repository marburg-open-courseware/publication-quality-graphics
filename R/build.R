#' @param ... Arguments passed to \code{\link[bookdown]{render_book}}.

buildBook = function(...) {
  
  ## if a previous build failed, '_main.Rmd' needs to be removed manually
  if (file.exists("_main.Rmd")) 
    jnk = file.remove("_main.Rmd")
  
  # render_book("index.Rmd", "bookdown::gitbook")
  bookdown::render_book(...)
  
  ## remove leading underscore ("_*") from image links 
  html = list.files(output_dir, pattern = ".html$", full.names = TRUE)
  
  for (i in html) {
    lns = readLines(i)
    file.remove(i)
    
    lns = gsub("_main_files/", "main_files/", lns)
    writeLines(lns, i)
  }
  
  ## remove leading underscore ("_*") from image subfolder
  mf = file.path(output_dir, "main_files")
  
  if (dir.exists(mf)) {
    jnk = suppressWarnings(
      try(unlink(mf, recursive = TRUE), silent = TRUE)
    )
    
    if (jnk != 0 | inherits(jnk, "try-error"))
      stop("Something went wrong when trying to delete ", mf, ".\n")
  }
  
  jnk = file.rename(file.path(output_dir, "_main_files")
                    , file.path(output_dir, "main_files"))

  cat("Process finished successfully.\n")
}

buildBook(input = "index.Rmd", output_format = "bookdown::gitbook"
          , clean = FALSE, output_dir = "book")
