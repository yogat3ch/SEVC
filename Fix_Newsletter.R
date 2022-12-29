


nm <- paste(
  lubridate::month(Sys.Date(), label = T, abbr = F),
  lubridate::year(Sys.Date())
)
get_update <- function(nm, from = "~/../Downloads") {
  f <- UU::list.files2(from, pattern = nm)
  f_p <- file.path("seva_newsletter", nm)
  if (!dir.exists(f_p))
    UU::mkpath(f_p)
  if (UU::is_legit(f)) {
    d_path <- file.path(f_p, basename(f))
    fs::file_move(f, d_path)
  } else {
    d_path <- UU::list.files2(f_p, pattern = nm) |> 
      stringr::str_subset(stringr::fixed("UPDATE"))
  }
  
  
  if (!UU::is_legit(d_path)) {
    stop("No file found in ",from, " or ", f_p)
  } 
    
  d_path
}

#  Read file ----
# Fri Feb 12 09:44:30 2021
# Assumes update is for current month/year

file <- get_update(nm)
path <- dirname(file)  

   
lines <- readr::read_lines(file) |> 
  # Fix Extra Parentheses in gte mso 9 comments
  stringr::str_replace("valign\\=\"top\"\\s\"", "valign=\"top\"") |> 
  # remove non utf8
  stringr::str_replace_all("‘|’", "'") |> 
  stringr::str_replace_all("–", "-")
  # add inherit background color to all divs (fixes issue viewing in Outlook via browser with empty interior div)
R.utils::insert(lines, stringr::str_which(lines, "\\<style")[1] + 1, "div {background-color:inherit}") |> 
  readr::write_lines(file)

htm <- xml2::read_html(file, encoding = "UTF8") # read the first

# Image handling ----
# Fri Feb 12 09:55:52 2021
imgs <- list(nodes = htm |>
               rvest::html_nodes(css = "img"))

.to_replace <- imgs$nodes |>
  rvest::html_attr("src") |>
  stringr::str_which("dhamma", negate = TRUE)

# Get the img urls which aren't already hosted on dhamma.org
imgs$urls <- imgs$nodes[.to_replace]
  

# Create dir for images
imgs$path <- file.path(path, "images")
if (!dir.exists(imgs$path)) 
  dir.create(imgs$path, showWarnings = T)
  
# write images to file
imgs$names <- purrr::map2(
  .x = imgs$urls,
  .y = seq_along(imgs$urls) |> paste(".jpg", sep = ""),
  .f = ~ {
    .img <- magick::image_read(rvest::html_attr(.x, "src"))
    if (magick::image_info(.img)[["width"]] > 600) {
      .img <- magick::image_scale(.img, "600x")
    }
    magick::image_write(.img,
      path = file.path(path, "images", .y),
      form = "jpg"
    )
  }
)



# RWordpress fixed by josephguillaume/XMLRPC
imgs$wp <- purrr::map(imgs$names, function(x) {
  RWordPress::uploadFile(x, file.path(
    "Newsletters",
    basename(path)
  ), overwrite = TRUE)
})
  
# Replace URLS
purrr::walk2(imgs$nodes[.to_replace], imgs$wp, ~xml2::xml_set_attr(.x, "src", .y$url))

# Replace text values ----
# Fri Feb 12 10:04:35 2021

# Make Update Text based on filename
.update_text <- paste(basename(path), snakecase::to_title_case(stringr::str_extract(basename(file), glue::glue("(?<={basename(path)})[^\\.]+"))))

# Replace MC Preview
purrr::iwalk(c(
  `Date in top left` = "//*[@id='templatePreheader']/table/tbody/tr/td/table/tbody/tr/td/div",
  `Email preview text` = "/html/body/span",
  `Page title text` = "/html/head/title"
), ~ {
  htm |>
    rvest::html_node(xpath = .x) |>
    xml2::xml_set_text(.update_text)
  message(paste(.y, "changed to:", .update_text))
})

#  Fix image alignment ----
# Fri Feb 12 10:15:47 2021

# ----------------------- Thu Apr 25 20:22:55 2019 ------------------------#
# For Side by Side Images

imgs$tbls <- htm |>
  rvest::html_nodes(".mcnImageGroupContentContainer")
imgs$xml <- purrr::map(imgs$tbls, ~rvest::html_node(.x, "img"))

if (!rlang::is_empty(imgs$xml)) {
  purrr::walk2(imgs$tbls, imgs$xml, ~xml2::xml_replace(.x, .y))
  
  htm |>
    rvest::html_nodes(".mcnImageGroupBlock") |>
    purrr::walk(~{
      xml2::xml_attr(.x, "style") <- "text-align:center;"
    })
  
  # add a td break in between pairs of images
  raw_htm <- readr::read_lines(as(htm, "character"))
  purrr::walk(imgs$xml[seq(1, length(imgs$xml), by = 2)], ~ {
    .i <- grep(xml2::xml_attr(.x, "src"), raw_htm, fixed = T)
    raw_htm[.i] <<- gsub(paste0("(?<=\\>)(?=\\<img)"), "</td><td>", raw_htm[.i], perl = T)
  })
  
htm <- xml2::read_html(glue::glue_collapse(raw_htm, sep = "\n"))
}

# ----------------------- Thu Apr 25 20:23:05 2019 ------------------------#
# For Single images

purrr::walk(imgs$nodes, ~xml2::xml_set_attr(xml2::xml_parent(.x), attr = "align", value = "center"))

#  Write the file ----
# Fri Feb 12 16:53:00 2021
.update <- file.path(getwd(), path, paste0(basename(path), "_Update.html"))
xml2::write_html(htm, file = .update)

# Fix table width for display on blogpost
htm |> 
  rvest::html_nodes("center") |> 
  rvest::html_nodes(xpath = "//*[@width='600']") |> 
  purrr::walk(~{
    xml2::xml_set_attr(.x, "width", NULL)
  })

# Write the body
xml2::write_html(htm |> rvest::html_nodes("center"), file = file.path(path, paste0(basename(path), "_Body.html")))

# Write the head
xml2::write_html(htm |> rvest::html_nodes("head"), file = file.path(path, paste0(basename(path), "_Head.html")))

shell.exec(.update)
