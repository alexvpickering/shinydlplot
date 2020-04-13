# attach css and shinyBS dependencies
with_deps <- function(markup) {

  addResourcePath(
    prefix = 'css',
    directoryPath = system.file('css', package='shinydlplot'))

  addResourcePath("sbs", system.file("www", package="shinyBS"))

  shinyBSDep <- htmltools::htmlDependency(
    "shinyBS",
    packageVersion("shinyBS"),
    src = c("href" = "sbs"),
    script = "shinyBS.js",
    stylesheet = "shinyBS.css")

  tagList(
    singleton(tags$head(
      tags$link(rel = 'stylesheet',
                type = 'text/css',
                href = 'css/shinydlplot.css'),
      shinyBSDep)
    ),
    markup
  )
}
