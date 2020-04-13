#' Interact with the test unit GUI in Komodo/SciViews-K
#'
#' These functions allow controlling the test unit module (R Unit tab at right)
#' in Komodo with SciViews-K and SciViews-K Unit extensions. R must be correctly
#' connected to Komodo, meaning that the 'svGUI' package must be loaded with
#' proper configuration of client/server socket connections between R and
#' Komodo. See the manual about SciViews-K for more information. The functions
#' defined here are the same as JavaScript functions defined in the 'sv.r.unit'
#' namespace in Komodo/SciViews-K Unit. For instance, [koUnit_runTest()] is
#' equivalent to `sv.r.unit.runTest();` in a Javascript macro in Komodo.
#'
#' @param state `TRUE` or `FALSE`, or missing for `koUnit_showRUnitPane()`, in
#' this case, the R Unit pane visibility is toggled.
#'
#' @return
#' [koUnit_isAutoTest()] returns `TRUE` if the test unit is in auto mode in
#' Komodo (the selected tests are run automatically each time a .R file
#' edited in Komodo is saved).
#'
#' [koUnit_version()] returns the version for which the SciViews-K Unit
#' extension was designed for. This allow to check if this version is compatible
#' with current 'svUnit' R package version, and to propose to update the Komodo
#' extension if needed (this mechanism is not running currently, but it will be
#' implemented in the future to avoid or limit incompatibilities between
#' respective R and Komodo extensions).
#'
#' The other functions are invoked for their side-effect and they return
#' nothing. Note, however, that correct execution of this code in Komodo is
#' verified, and the functions issue an error in R if they fail to execute
#' correctly in Komodo.
#'
#' @export
#' @name koUnit
#' @author Philippe Grosjean
#' @seealso [guiTestReport()]
#' @keywords utilities
#' @concept unit testing
#' @examples
#' \dontrun{
#' # Make sure R is communicating with Komodo before use, see ?koCmd in svGUI
#' koUnit_version()
#'
#' # Toggle visibility of the R Unit pane in Komodo twice
#' koUnit_showRUnitPane()
#' koUnit_showRUnitPane()
#'
#' # Make sure that the R Unit pane is visible
#' koUnit_showRUnitPane(TRUE)
#'
#' # Is the test unit running in auto mode?
#' koUnit_isAutoTest()
#'
#' # Toggle auto test mode off
#' koUnit_setAutoTest(FALSE)
#'
#' # Run the test units from within Komodo
#' koUnit_runTest()
#' }
koUnit_setAutoTest <- function(state) {
  if (isTRUE(state)) state <- "true" else state <- "false"
  res <- .koUnit('sv.r.unit.setAutoTest(<<<data>>>);', data = state)
}

.koUnit <- function(cmd, warn = FALSE, ...) {
  # Look if koCmd() exists, otherwise, we are probably not connected to Komodo
  if (exists("koCmd", mode = "function")) {
    res <- get("koCmd")(cmd, ...)
    if (isTRUE(warn) & inherits(res, "try-error"))
      warning("Komodo is not available or did not process this command correctly")
    return(res)
  } else {
    if (isTRUE(warn))
      warning("You must establish a connection with Komodo/SciViews-K to use this function")
  }
}

#' @export
#' @rdname koUnit
koUnit_isAutoTest <- function() {
  res <- .koUnit('sv.socket.serverWrite(sv.r.unit.isAutoTest());')
  return(res == "true")
}

#' @export
#' @rdname koUnit
koUnit_runTest <- function()
  res <- .koUnit('sv.r.unit.runTest();')

#' @export
#' @rdname koUnit
koUnit_showRUnitPane <- function(state) {
  if (missing(state)) {
    state <- ""
  } else if (isTRUE(state)) {
    state <- "true"
  } else {
    state <- "false"
  }
  res <- .koUnit('sv.r.unit.showRUnitPane(<<<data>>>);', data = state)
}

#' @export
#' @rdname koUnit
koUnit_version <- function()
  .koUnit('sv.socket.serverWrite(sv.r.unit.version + "." + sv.r.unit.release);')
