.onLoad <- function(...) {
  # Create link to javascript and css files for package
  shiny::addResourcePath("sdp", system.file("css", package="shinydlplot"))
}


# attach css and shinyBS dependencies
with_deps <- function(markup) {


  shinyBSDep <- htmltools::htmlDependency(
    "shinyBS",
    packageVersion("shinyBS"),
    src = c("href" = "sbs"),
    script = "shinyBS.js",
    stylesheet = "shinyBS.css")

  shinydlplotDep <- htmltools::htmlDependency(
    'shinydlplot',
    packageVersion('shinydlplot'),
    src = c("href" = "sdp"),
    stylesheet = "shinydlplot.css")

  tagList(
      bootstrapLib(),
      shinyBSDep,
      shinydlplotDep,
    markup
  )
}
