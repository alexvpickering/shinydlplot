#' UI for plotly with download data button in modebar
#'
#' @param id id string that gets namespaced by \code{shiny::NS}.
#' @inheritParams plotly::plotlyOutput
#' @export
#' @seealso \code{\link[shiny]{NS}}, \code{\link{downloadablePlotly}}
#'
#' @examples
#' library(shiny)
#' library(shinyjs)
#' library(shinydlplot)
#' library(plotly)

#' ui <- fluidPage(
#'   useShinyjs(),
#'   downloadablePlotlyUI(id = 'iris')
#' )

#' server <- function(input, output, session) {
#'
#'   plot <- plot_ly(data = iris, x = ~Sepal.Length, y = ~Petal.Length)
#'
#'   callModule(downloadablePlotly,
#'              id = 'iris',
#'              plot = plot,
#'              filename = 'iris.csv',
#'              content = function(file) {write.csv(iris, file)})
#' }
#'
#' shinyApp(ui, server)
#'
downloadablePlotlyUI <- function(id, width = '100%', height = 'auto', inline = FALSE) {
  ns <- shiny::NS(id)
  shiny::tagList(
    hiddenDownloadUI(ns('dl_plotly')),
    plotly::plotlyOutput(ns('plotly'), width = width, height = height, inline = inline)
  )
}

#' Server-side logic for plotly with download data button in modebar
#'
#' @param plot Object of class \code{'plotly'} or a function or reactive that generates one.
#' @param title Text for plotly tooltip.
#' @inheritParams hiddenDownload
#' @seealso \code{\link{downloadablePlotlyUI}}
#' @export
#'
downloadablePlotly <- function(input, output, session, plot, filename, content, title = 'Download plot data') {

  # hidden download link
  shiny::callModule(hiddenDownload, 'dl_plotly',
                    check = reactive(input$dl_data),
                    filename = filename,
                    content = content)

  # make plot a reactive
  plotly_fun <- shiny::reactive({
    if (is(plot, c('function', 'reactive'))) plot <- plot()
    return(plot)
  })


  # wrap to avoid shinytest errors
  output$plotly <- shiny::snapshotPreprocessOutput(
    plotly::renderPlotly({

      # id of ns_val to invalidate on click
      ns_id = session$ns('dl_data')

      # button to add to modebar
      dl_data_button <- list(
        name = title,
        icon = list(
          path = "M216 0h80c13.3 0 24 10.7 24 24v168h87.7c17.8 0 26.7 21.5 14.1 34.1L269.7 378.3c-7.5 7.5-19.8 7.5-27.3 0L90.1 226.1c-12.6-12.6-3.7-34.1 14.1-34.1H192V24c0-13.3 10.7-24 24-24zm296 376v112c0 13.3-10.7 24-24 24H24c-13.3 0-24-10.7-24-24V376c0-13.3 10.7-24 24-24h146.7l49 49c20.1 20.1 52.5 20.1 72.6 0l49-49H488c13.3 0 24 10.7 24 24zm-124 88c0-11-9-20-20-20s-20 9-20 20 9 20 20 20 20-9 20-20zm64 0c0-11-9-20-20-20s-20 9-20 20 9 20 20 20 20-9 20-20z",
          transform = " ",
          width =  564,
          ascent = 564,
          descent = 0
        ),
        click = htmlwidgets::JS(
          paste0("function(gd) {
             // priority 'event' causes invalidation irrespective of value
             Shiny.setInputValue('", ns_id, "', 'bar', {priority: 'event'});
          }")
        )
      )

      plotly_fun() %>%
        plotly::config(modeBarButtonsToAdd = list(dl_data_button))
    }),
    function(value) { session$ns('downloadable_plotly') }
  )
}
