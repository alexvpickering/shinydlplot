.onLoad <- function(...) {
  # Create link to javascript and css files for package
  shiny::addResourcePath("sdp", system.file("css", package="shinydlplot"))
  shiny::addResourcePath("sbs", system.file("www", package="shinyBS"))
}


# attach css and shinyBS dependencies
with_deps <- function(markup) {


  shinyBSDep <- htmltools::htmlDependency(
    "shinyBS",
    utils::packageVersion("shinyBS"),
    src = c("href" = "sbs"),
    script = "shinyBS.js",
    stylesheet = "shinyBS.css")

  shinydlplotDep <- htmltools::htmlDependency(
    'shinydlplot',
    utils::packageVersion('shinydlplot'),
    src = c("href" = "sdp"),
    stylesheet = "shinydlplot.css")

  tagList(
      bootstrapLib(),
      shinyBSDep,
      shinydlplotDep,
    markup
  )
}
