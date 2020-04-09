#' Server-side logic for plot with download data button
#'
#' Download button appears on hover in top right.
#'
#' @param plot A \code{ggplot2} object or a function or reactive that generates a plot.
#' @param title Text for plotly tooltip.
#' @inheritParams hiddenDownload
#' @param ... additional named arguments passed to \code{renderPlot}.
#' @seealso \code{\link{downloadablePlotUI}}, \code{\link{renderPlot}}.
#' @export
#'
#' @examples
#' library(shiny)
#' library(shinyjs)
#' library(shinydlplot)
#' library(ggplot2)

#' ui <- fluidPage(
#'   useShinyjs(),
#'   downloadablePlotUI(id = 'iris_plot')
#' )

#' server <- function(input, output, session) {
#'
#'   plot <- ggplot(iris, aes(x = Sepal.Length, y = Petal.Length)) + geom_point()
#'
#'   callModule(downloadablePlot,
#'              id = 'iris_plot',
#'              plot = plot,
#'              filename = 'iris.csv',
#'              content = function(file) {write.csv(iris, file)})
#' }
#'
#' shinyApp(ui, server)
#'
#'
downloadablePlot <- function(input, output, session, plot, filename, content, ...) {



  # make plot a reactive
  plot_fun <- shiny::reactive({
    if (is(plot, c('function', 'reactive'))) plot <- plot()
    return(plot)
  })

  # hide download button if no plot or content
  downloadable <- shiny::reactive({
    exists('content') & isTruthy(plot_fun())
  })

  observe({
    shinyjs::toggleClass('download_container', class = 'visible-plot', condition = downloadable())
  })


  # click download
  output$download <- shiny::downloadHandler(
    filename = filename,
    content = content
  )

  output$dl_plot <- shiny::renderPlot({
    plot_fun()
  }, ...)
}

#' UI for plot with download data button
#'
#' @param id id string that gets namespaced by \code{shiny::NS}.
#' @param ... Named arguments passed to \code{plotOutput}.
#' @export
#' @seealso \code{\link[shiny]{NS}}, \code{\link{downloadablePlot}}, \code{\link{plotOutput}}
#'
#'
downloadablePlotUI <- function(id, ...) {
  ns <- NS(id)

  # grab css
  dlplot_css <- .get_script("dlplot.css", "css")

  shiny::withTags({
    shiny::tagList(
      shiny::singleton(tags$head(tags$style(HTML(dlplot_css)))),
      div(class = 'downloadable-plot', id = ns('plot_container'),
          div(class = 'clearfix',
              span(
                id = ns('download_container'), class = 'pull-right downloadable-plot-btn',
                shiny::downloadButton(ns('download'), label = NULL, icon = icon('download', 'fa-fw')),
                shinyBS::bsTooltip(
                  ns('download'),
                  'Download plot data',
                  placement = 'left',
                  options = list(
                    container = 'body',
                    template = '<div class="tooltip plot" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
                  ))
              )
          ),
          shiny::plotOutput(ns('dl_plot'), ...)

      )
    )
  })
}

#In order to load the javascript and css we can first load it to a character var
.get_script <- function(title, type){
  fname <- system.file(type, title, package = "shinydlplot")
  readChar(fname, file.info(fname)$size)
}
