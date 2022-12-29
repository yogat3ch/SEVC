# Resize images ----
# Wed Dec 16 11:28:26 2020
jobs::jobscript({
  library(magrittr)
dirs <- list.dirs("sevc.yogat3ch.net/media") %>% 
  stringr::str_subset("Dhamma_Patapa")
set_basenames <- rlang::as_function(~{
  setNames(.x, basename(.x))
})
web_img <- function(path, overwrite = TRUE) {
  path <- stringr::str_remove(path, "[\\/\\\\]+$")
  imgs <- set_basenames(list.files(path, full.names = T)) %>% 
    purrr::map(~{
      .img <- magick::image_read(.x)
      list(img = .img,
           info = magick::image_info(.img))
      
    }) %>% 
    purrr::transpose()
  imgs$info <- dplyr::bind_rows(imgs$info, .id = "filename")
  
  .need_compression <- imgs$img[dplyr::filter(imgs$info, width > 1500)$filename]
  if (is.character(overwrite)) {
    names(.need_compression) <- paste0(overwrite, names(.need_compression))
  } else if (isFALSE(overwrite)) {
    names(.need_compression) <- paste0("web_img", names(.need_compression))
  }
  purrr::iwalk(.need_compression, ~{
    .info <- magick::image_info(.x)
    .img <- magick::image_resize(.x, geometry = "1500x")
    message("Writing: ",.y)
    .d <- as.numeric(stringr::str_extract(.info$density, "\\d+"))
    magick::image_write(.img, path = file.path(path, .y), format = .info$format, density = ifelse(.d > 75, 75, .d))
  })
}
  
  

purrr::walk(dirs, web_img)

}, filename = "resize_images", dir = "jobs", workingDir = getwd())


if (!dir.exists("images")) {
  dir.create(file.path(getwd(), .path, "images"), showWarnings = T)
  imgs$names <-
    purrr::map2(
      .x = imgs$urls,
      .y = seq_along(imgs$urls) %>% paste(".jpg", sep = ""),
      .f = ~ {
        .img <- magick::image_read(.x)
        if (magick::image_info(.img) %>% magrittr::extract2("width") > 600) {
          .img <- magick::image_scale(.img, "600x")
        }
        magick::image_write(.img,
                            path = file.path(.path, "images", .y),
                            form = "jpg"
        )
      }
    )
}