#' UI for hidden download link
#' @param id id string to be namespaced.
#' @export
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
#' @export
#' @seealso \code{\link{hiddenDownload}}
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
