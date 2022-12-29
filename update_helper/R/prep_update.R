update_prep <- function(sections, date = lubridate::today(), template_file = dirs$extdata("update_template.html")) {
  y <- lubridate::year(date)
  m <- lubridate::month(date)
  d <- lubridate::day(date)

  update <- xml2::read_html(template_file)
  # Full Update button ----
  # Thu Dec 29 13:46:25 2022
  update_button <- update |>
    rvest::html_element(".login-button")
  xml2::xml_attr(update_button, "href") <- httr::modify_url(rvest::html_attr(update_button, "href"), path = c(y, glue::glue("{y}-{m}")))
  # MC Text  ----
  # Thu Dec 29 13:47:19 2022
  preview_text <- glue::glue("{month.name[m]} {y} Update")
  purrr::walk(c("title", "span.mcnPreviewText"), ~update |>
                rvest::html_element(.x) |>
                xml2::`xml_text<-`(preview_text))
  # Buddha Quote ----
  # Thu Dec 29 13:57:33 2022
  update |>
    rvest::html_element("#buddha-quote") |>
    xml2::xml_replace(sections$buddhaquote)

  # Sections ----
  # Thu Dec 29 16:50:44 2022
  body <- update |>
    rvest::html_element("#templateBody")
  purrr::walk(sections$sections, ~{
    # Add header
    if (section_has$header(.x))
      xml2::xml_add_child(body, section_header(.x))
    if (section_has$img(.x))
      xml2::xml_add_child(body, section_image(.x))
    # Add content
    if (section_has$text_content(.x))
      xml2::xml_add_child(body, section_text_content(.x))
  })
  # International Vipassana Newsletter ----
  # Thu Dec 29 16:50:51 2022
  update |>
    rvest::html_element("#update-ivn") |>
    xml2::xml_replace(section_boxed_text(sections$IVN))

  return(update)
}

update_write <- function(update, file = "update_final.html") {
  xml2::write_html(update, file = file)
}

update_get_sections <- function(date = lubridate::today(), root_url = "https://www.patapa.dhamma.org/") {
  post <- wordpressr::get_wp_posts(root_url, post_count = 1, after_date = lubridate::floor_date(date, unit = "month"))
  htm <- xml2::read_html(post$content)
  list(buddhaquote = rvest::html_node(htm, "#buddha-quote"),
       sections = rvest::html_nodes(htm, ".update"),
       IVN = rvest::html_nodes(htm, "#update-ivn"))
}
 # Need changing of MC PREVIEW * TITLE from old computer
# sections <- update_get_sections()
section_boxed_text <- function(content, template = dirs$extdata("mc_boxed_text.html")) {
  htm <- xml2::read_xml(template, options = c("IGNORE_ENC"))
  xml2::xml_add_child(rvest::html_element(htm, "td.mcnTextContent"), .value = rvest::html_element(content, ".update-content"))
  htm
}

section_text <- function(content, template = dirs$extdata("mc_text.html")) {
  htm <- xml2::read_xml(template, options = c("IGNORE_ENC"))
  xml2::xml_add_child(rvest::html_element(htm, "td.mcnTextContent"), .value = rvest::html_element(content, ".update-content"))
  htm
}


section_has <- purrr::map(
  c(header = "h1",
                     text_content = ".update-content",
                     img = "img"),
  ~rlang::new_function(rlang::pairlist2(section= , has = .x), rlang::expr({!rlang::is_empty(rvest::html_element(section, has))})))

section_header <- function(el, url = NULL, text = NULL, template = dirs$extdata("mc_header.html")) {
  htm <- xml2::read_xml(template)
  if (!missing(el)) {
    if (is.null(url))
      url <- rvest::html_node(el, "div.header-bg") |>
      rvest::html_attr("style") |>
      stringr::str_extract("(?<=url\\(\\')[^\\)\\']+")

    if (is.null(text))
      text <- rvest::html_node(el, "h1") |>
        rvest::html_text()
  }
  htm |>
    rvest::html_element("table.bg") |>
    xml2::xml_set_attr("background", url)
  htm |>
    rvest::html_element("h1") |>
    xml2::`xml_text<-`(text)
  htm
}

section_image <- function(el, src = NULL, template = dirs$extdata("mc_img.html")) {
  if (!missing(el)) {
    if (is.null(src))
      src <- rvest::html_element(el, "img") |>
      rvest::html_attr("src")
  }
  htm <- xml2::read_xml(template)
  htm |>
    rvest::html_element("img") |>
    xml2::`xml_attr<-`("src", src)
  htm
}
