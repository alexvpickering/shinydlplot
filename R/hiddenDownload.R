#' UI for hidden download link
#' @param id id string to be namespaced.
#' @export
#'
#' @return a shiny.tag used to create a hidden download link.
#' @seealso \code{\link[shiny]{NS}}, \code{\link{hiddenDownload}}
#' @keywords internal
#'
hiddenDownloadUI <- function(id) {
  ns <- NS(id)
  downloadLink(ns("downloadData"), '')
}


#' Logic for hidden download link
#' @param check reactive value to trigger download.
#' @param input,output,session standard \code{shiny} boilerplate.
#' @inheritParams shiny::downloadHandler
#'
#' @return No return value, called to generate logic for hidden download link.
#' @seealso \code{\link{hiddenDownload}}
#' @export
#' @keywords internal
hiddenDownload <- function(input, output, session, check, filename, content) {

  observeEvent(check(), {
    shinyjs::runjs(paste0("$('#", session$ns('downloadData'), "')[0].click();"))
  })

  output$downloadData <- downloadHandler(
    filename = filename,
    content = content
  )
}
