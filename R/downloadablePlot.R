#' @import shiny
NULL

#' Server-side logic for plot with download data button
#'
#' Download button appears on hover in top right.
#'
#' @param plot A \code{ggplot2} object or a function or reactive that generates a plot.
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


  # click download
  output$download <- downloadHandler(
    filename = filename,
    content = content
  )

  output$dl_plot <- renderPlot({
    plot_fun()
  }, ...)
}

#' UI for plot with download data button
#'
#' @param id id string that gets namespaced by \code{shiny::NS}.
#' @param title Text to display on hover of download button.
#' @inheritParams shiny::plotOutput
#' @export
#' @seealso \code{\link[shiny]{NS}}, \code{\link{downloadablePlot}}, \code{\link{plotOutput}}
#'
#'
downloadablePlotUI <- function(id, title = 'Download plot data', width = '100%', height = '400px') {
  ns <- NS(id)


  res <- div(class = 'downloadable-plot', id = ns('plot_container'),
      div(class = 'clearfix',
          span(
            id = ns('download_container'), class = 'pull-right downloadable-plot-btn',
            downloadButton(ns('download'), label = NULL, icon = icon('download', 'fa-fw')),
          )
      ),
      plotOutput(ns('dl_plot'), width = width, height = height),
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
