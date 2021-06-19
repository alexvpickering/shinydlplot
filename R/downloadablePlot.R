#' @import shiny
NULL

#' Server-side logic for plot with download data button
#'
#' Download button appears on hover in top right.
#'
#' @param plot A \code{ggplot2} object or a function or reactive that generates a plot.
#' @inheritParams hiddenDownload
#' @param ... additional named arguments passed to \code{renderPlot}.
#'
#' @return No return value, called to generate server logic.
#' @seealso \code{\link{downloadablePlotUI}}, \code{\link{renderPlot}}.
#' @export
#'
#' @examples
#' library(shiny)
#' library(shinyjs)
#' library(shinydlplot)
#' library(ggplot2)
#'
#' ui <- fluidPage(
#'   useShinyjs(),
#'   downloadablePlotUI(id = 'iris_plot')
#' )
#'
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
#' \dontrun{shinyApp(ui, server)}
#'
#'
downloadablePlot <- function(input, output, session, plot, filename, content, ...) {


  # make plot a reactive
  plot_fun <- reactive({
    if (methods::is(plot, c('function', 'reactive'))) plot <- plot()
    return(plot)
  })

  # hide download button if no plot or content
  downloadable <- reactive({
    exists('content') & isTruthy(plot_fun())
  })

  observe({
    shinyjs::toggleClass('download_container', class = 'visible-plot', condition = downloadable())
  })

  # zoomable plot
  ranges <- reactiveValues(x = NULL, y = NULL)

  # When a double-click happens, check if there's a brush on the plot.
  # If so, zoom to the brush bounds; if not, reset the zoom.
  observeEvent(input$plot_dblclick, {
      brush <- input$plot_brush
      if (!is.null(brush)) {
        ranges$x <- c(brush$xmin, brush$xmax)
        ranges$y <- c(brush$ymin, brush$ymax)

      } else {
        ranges$x <- NULL
        ranges$y <- NULL
      }
  })


  # click download
  output$download <- downloadHandler(
    filename = filename,
    content = content
  )

  output$dl_plot <- renderPlot({
    plot <- plot_fun()

    plot +
      ggplot2::coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = FALSE)
  }, ...)

}

#' UI for plot with download data button
#'
#' @param id id string that gets namespaced by \code{shiny::NS}.
#' @param title Text to display on hover of download button.
#' @param zoom if \code{TRUE} brush then double-click to zoom.
#' @inheritParams shiny::plotOutput
#'
#' @return an HTML tag object corresponding to the UI for \code{downloadablePlot}.
#' @seealso \code{\link[shiny]{NS}}, \code{\link{downloadablePlot}}, \code{\link{plotOutput}}
#' @export
#'
#'
downloadablePlotUI <- function(id, title = 'Download plot data', width = '100%', height = '400px', zoom = FALSE) {
  ns <- NS(id)

  brush <- dblclick <- NULL
  if (zoom) {
    brush <- list(id = ns('plot_brush'), resetOnNew = TRUE)
    dblclick <- ns('plot_dblclick')
  }

  res <- div(class = 'downloadable-plot', id = ns('plot_container'),
      div(class = 'clearfix',
          span(
            id = ns('download_container'), class = 'pull-right downloadable-plot-btn',
            downloadButton(ns('download'), label = NULL, icon = icon('download', 'fa-fw')),
          )
      ),
      plotOutput(ns('dl_plot'), width = width, height = height, brush = brush, dblclick = dblclick),
      shinyBS::bsTooltip(
        ns('download'),
        title,
        placement = 'left',
        options = list(
          container = 'body',
          template = '<div class="tooltip plot" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
        ))

  )

  with_deps(res)
}
