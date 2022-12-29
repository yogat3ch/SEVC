googlesheets4::gs4_auth(path = "inst/vault/rstudio@adept-eon-198316.iam.gserviceaccount.com.json")
id <- googlesheets4::as_sheets_id("1mRfVZYzyJxWX5iEkSO4wmUn5dDhOYkjbnfUoFBjZ5PE")
group_sits <- googlesheets4::read_sheet(id)
googlema
group_sits <- group_sits |>
  dplyr::mutate(Phone = glue::glue('=hyperlink("tel:{stringr::str_remove_all(Phone, "[^0-9]*")}", "{Phone}")'),
                Email = googlesheets4::gs4_formula(glue::glue('=hyperlink("mailto:{trimws(Email)}", "{Email}")')))
googlesheets4::write_sheet(group_sits, id, sheet = "Sheet1")
