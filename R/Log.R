#' SciViews-R log management functions
#'
#' These functions define the code of test functions. They are designed to check
#' the result of some test calculation.
#'
#' @param description A (short) character string describing this test suite log.
#' @param deleteExisting Do we delete an existing a `.Log` object already
#' defined in `.GlobalEnv` (no, by default)?
#' @param stopit Do we issue an error ([stop()] in case of any error or failure?
#' This is particularly useful if you want to interrupt R CMD check on packages,
#' when you included one or more test suites in examples (see `?unitTests`).
#' @param summarize Should the summary of the log be printed in case we stop
#' execution of the code when an error is found (see `stopit =` argument. It is,
#' indeed, useful to indicate at this time which tests failed or raised an
#' error. So, this argument should usually be left at its default value.
#'
#' @return
#' [Log()] and [createLog()] return the `.Log` object defined in `.GlobalEnv` by
#' reference (it is indeed an environment). So, you can use its content (and
#' change it, if you write functions to manipulate this log).
#'
#' [clearLog()] return invisibly `TRUE` or `FALSE`, depending if an existing log
#' object was deleted or not.
#'
#' [errorLog()] is mainly used for its side-effect of stopping code execution
#' and/or printing a summary of the test runs in the context of example
#' massaging in R CMD check (see the "Writing R extensions" manual). However,
#' this function also returns invisibly a contingency table with the number of
#' successes, failures, errors and deactivated tests recorded so far.
#'
#' [lastTest()] and [lastSuite()] recall results of last test and last suite
#' run, respectively.
#'
#' @details
#' svUnit records results of assertions (using the checkxxx() functions) in a
#' 'svSuiteData' object named `.Log` and located in .GlobalEnv. Hence, this log
#' is easy to access. However, in order to avoid errors in your code in case
#' this object was deleted, or not created, it is better to access it using
#' [Log()] which take care to create the object if it is missing.
#'
#' @export
#' @importFrom utils sessionInfo str
#' @author Philippe Grosjean
#' @seealso [svSuiteData()], [svSuite()], [svTest()], [checkEquals()]
#' @keywords utilities
#' @concept unit testing
#' @examples
#' clearLog()           # Clear the svUnit log
#'
#' # Two correct tests
#' (checkTrue(1 < 2))
#' (checkException(log("a")))
#' errorLog()           # Nothing, because there is no error
#'
#' \dontrun{
#' (checkTrue(1 > 2))    # This test fails
#' lastTest()            # Print results of last test
#' errorLog()            # Stop and summarize the tests run so far
#' }
#'
#' clearLog()
Log <- function(description = NULL) {
  if (!exists(".Log", envir = .GlobalEnv, inherits = FALSE))
    createLog(description = description)
  get(".Log", envir = .GlobalEnv, inherits = FALSE)
}

#' @export
#' @rdname Log
createLog <- function(description = NULL, deleteExisting = FALSE) {
  # Create a log consisting in an environment with class svSuiteData
  if (isTRUE(deleteExisting) && exists(".Log", envir = .GlobalEnv,
    inherits = FALSE)) rm(.Log, envir = .GlobalEnv)
  if (!exists(".Log", envir = .GlobalEnv, inherits = FALSE)) {
    .Log <<- structure(new.env(parent = .GlobalEnv),
      class = c("svSuiteData", "environment"))
    # Add general informations and variables to it
    .Log$.time <- Sys.time()            # Creation time of the log
    .Log$.R.version <- R.version        # R version
    .Log$.sessionInfo <- sessionInfo()  # Information about current session
    .Log$.description <- description    # Optional description of this log
    # Create ..xxx variables used for test context
    # Note: never delete or put NULL in these variables, use "" instead
    .Log$..Unit <- ""
    .Log$..Msg <- ""
    .Log$..Obj <- ""
    .Log$..File <- ""
    .Log$..Tag <- ""
    # Create .lastTest that contains details from last check...()
    naChr <- as.character(NA)
    .Log$.lastTest <- structure(
      data.frame(msg = naChr, call = naChr,
        timing = as.numeric(NA), kind = .kind(NA), res = naChr,
        obj = naChr, file = naChr, tag = naChr,
        stringsAsFactors = FALSE),
      class = c("svTestData", "data.frame"))
    # Create .lastSuite with an empty list of test units to run
    .Log$.lastSuite <- list()
  }
}

#' @export
#' @rdname Log
clearLog <- function() {
  if (exists(".Log", envir = .GlobalEnv, inherits = FALSE)) {
    rm(list = ".Log", envir = .GlobalEnv)
    res <- TRUE
  } else {
    res <- FALSE
  }
  invisible(res)
}

#' @export
#' @rdname Log
errorLog <- function(stopit = TRUE, summarize = TRUE) {
  .Log <- Log()
  Res <- table(stats(.Log)$kind)
  if (isTRUE(stopit) && any(Res[2:3] > 0)) {
    if (isTRUE(summarize))
      summary(.Log)
    msg <- paste(Res[2], "failure(s) and", Res[3], "error(s)")
    stop(msg)
  } else if (interactive()) {
    cat("Summary statistics on all tests run:\n")
    print(Res)
  }
  invisible(Res)
}

#' @export
#' @rdname Log
lastTest <- function() {
  # Return a svTestData object with data from last recorded test
  Log()$.lastTest
}

#' @export
#' @rdname Log
lastSuite <- function() {
  # Return data about last suite run
  Log()$.lastSuite
}
