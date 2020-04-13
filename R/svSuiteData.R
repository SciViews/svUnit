#' Objects of class 'svSuiteData' contain results from running test suites
#'
#' The 'svSuiteData' object contains results of all test run in one or more test
#' suites. The `checkxxx()` functions and the [runTest()] method generate data
#' (objects 'svTestData') contained in the default 'svSuiteData' named `.Log`
#' and located in `.GlobalEnv`. It is then possible to display and report
#' information it contains in various ways to analyze the results.
#'
#' @param x Any kind of object, or a 'svSuiteData' object in the case of
#' [print()].
#' @param object A 'svSuiteData' object.
#' @param fields Character vector. The name of all metadata items you want to
#' extract for the object. The default value is an exhaustive list of all
#' available metadata (i.e., defined by default) in the object, but you can add
#' more: just add a corresponding attribute to your object.
#' @param all Do we print concise report for all test, or only for the tests
#' that fail or produce an error?
#' @param file Character. The path to the file where to write the report.
#' If `file = ""`, the protocol report is output to the console.
#' @param append Do we append to this file?
#' @param type Character. The type of protocol report to create. For the moment,
#' only `type = "text"` and `type = "junit"` are supported, but further types
#' (HTML, LaTeX, Wiki, etc.) could be provided later.
#' @param  ... Further arguments to pass to methods. Not used yet.
#'
#' @return
#' [is.svSuiteData()] returns `TRUE` if the object is an 'svSuiteData'. The
#' various methods serve to extract or print content in the object.
#'
#' @details
#' A 'svSuiteData' is, indeed, an environment. The results for the various tests
#' runs are in non hidden (i.e., names not starting with a dot) objects that are
#' of class 'svTestData' in this environment. Various other objects that control
#' the execution of the test, their context, etc. are contained as hidden objects
#' with name starting with a dot. Note that using an environment instead of a
#' list for this object allows for a call by reference instead of a usual call by
#' value in R, when passing this object to a function. This property is largely
#' exploited in all svUnit functions to make sure results of test runs are
#' centralized in the same log ('svSuiteData' object).
#'
#' @export
#' @name svSuiteData
#' @author Philippe Grosjean; Mario Frasca for the junit protocol.
#' @seealso [svSuite()], [is.svTestData()], [Log()], [checkEquals()]
#' @keywords utilities
#' @concept unit testing
#' @examples
#' clearLog()    # Clear any existing log
#'
#' # Run some tests
#' checkTrue(1 < 2)
#' checkException(log("a"))
#' foo <- function(x, y = 2)
#'   return(x * y)
#' test(foo) <- function() {
#'   checkEqualsNumeric(4, foo(2))
#'   checkEqualsNumeric(6, foo(2, nonexisting))
#'   checkTrue(is.test(foo))
#'   warning("This is a warning")
#'   cat("Youhou from test!\n")  # Don't use, except for debugging!
#'   checkTrue(is.test(test(foo)))
#'   checkIdentical(attr(foo, "test"), test(foo))
#'   checkException(foo(2, nonexisting))
#'   #DEACTIVATED("My deactivation message")
#'   checkException(foo(2))  # This test fails
#' }
#' runTest(foo)
#'
#' # Now inspect the log, which is a 'svSuiteData' object
#' is.svSuiteData(Log())
#' stats(Log())
#' metadata(Log())
#' Log()    # Print method
#' summary(Log())
#'
#' \dontrun{
#' # To get a print of the test protocol on file, use:
#' protocol(Log(), type = "text", file = "RprofProtocol.out")
#' file.show("RprofProtocol.out")
#' unlink("RprofProtocol.out")
#' }
#'
#' rm(foo)
#'
#' \dontrun{
#' # Profiling of very simple test runs
#' library(utils)
#' createLog(description = "test profiling", deleteExisting = TRUE)
#' imax <- 3
#' jmax <- 100
#' l <- 50
#' Rprof()
#' for (i in 1:imax) {
#'   # Change the context for these tests
#'   .Log$..Test <- paste("Test", i, sep = "")
#'   .Log$..Tag <- paste("#", i, sep = "")
#'   res <- system.time({
#'     for (j in 1:jmax) checkTrue(i <= j, "My test")
#'   }, gcFirst = TRUE)[3]
#'   print(res)
#'   flush.console()
#' }
#' Rprof(NULL)
#' # Look at profile
#' summaryRprof()
#' unlink("Rprof.out")
#'
#' # Look at the log
#' summary(Log())
#' }
is.svSuiteData <- function(x) {
  # It this a svSuiteData object
  inherits(x, "svSuiteData")
}

#' @export
#' @rdname svSuiteData
stats.svSuiteData <- function(object, ...) {
  if (!is.svSuiteData(object))
    stop("'object' must inherit from 'svSuiteData'")
  # Get the list of tests
  Tests <- ls(object)
  if (length(Tests) == 0) {
    # The object is empty!
    Res <- data.frame(kind = .kind(logical()), timing = numeric(),
      time = numeric(), unit = character(), tag = character(),
      msg = character(), stringsAsFactors = FALSE)
  } else {
    # Functions to get data for each test
    getKind <- function(x) .kindMax(x$kind)
    getTiming <- function(x) attr(x, "stats")["timing"]
    getTime <- function(x) attr(x, "time")
    getContext <- function(x, item) attr(x, "context")[[item]]
    Res <- data.frame(
      kind = rev(sapply(object, getKind)),
      timing = rev(sapply(object, getTiming)),
      time = structure(rev(sapply(object, getTime)),
        class = c("POSIXt", "POSIXct")),
      unit = rev(sapply(object, getContext, "unit")),
      msg = rev(sapply(object, getContext, "msg")),
        stringsAsFactors = FALSE)
  }
  Res
}

#' @export
#' @rdname svSuiteData
metadata <- function(object, ...)
  UseMethod("metadata")

#' @export
#' @rdname svSuiteData
metadata.svSuiteData <- function(object,
fields = c("R.version", "sessionInfo", "time", "description"), ...) {
  # Extract metadata information from a 'svSuiteData' object
  if (!is.svSuiteData(object))
    stop("'object' must inherit from 'svSuiteData'")
  # Return a list with all metadata elements found
  fields <- paste(".", fields, sep = "")
    Res <- list()
  for (F in fields)
    Res[[F]] <- object[[F]]
  Res
}

#' @export
#' @rdname svSuiteData
print.svSuiteData <- function(x, all = FALSE, file = "", append = FALSE, ...) {
  if (!is.svSuiteData(x))
    stop("'x' must inherit from 'svSuiteData'")
  Tests <- ls(x)
  if (length(Tests) == 0) {
    cat("No test records!\n", file = file, append = append)
  } else {
    # Print general information about the tests
    Stats <- stats(x)
    Tests <- rownames(Stats)  # To make sure we use the same!
    Timing <- .formatTime(sum(Stats$timing, na.rm = TRUE), secDigits = 1)
    cat("= A svUnit test suite", Timing, " with:\n\n", sep = "",
      file = file, append = append)
    cat(paste("* ", Tests, " ... ", as.character(Stats$kind), "",
      sep = "", collapse = "\n"),
      "\n\n", sep = "", file = file, append = TRUE)

    # Print detailed information about each test
    for (Test in Tests)
      print(x[[Test]], all = all, file = file, append = TRUE, ...)
  }
  invisible(x)
}

#' @export
#' @rdname svSuiteData
summary.svSuiteData <- function(object, ...)
    protocol_text.svSuiteData(object, ...)

#' @export
#' @rdname svSuiteData
protocol <- function(object, type = "text", file = "", append = FALSE, ...)
  UseMethod("protocol")

#' @export
#' @rdname svSuiteData
protocol.default <- function(object, type = "text", file = "",
append = FALSE, ...)
  get(paste("protocol", type[1], sep = "_"))(object, file = file,
    append = append, ...)

#' @export
#' @rdname svSuiteData
protocol.svSuiteData <- function(object, type = "text", file = "",
append = FALSE, ...)
  get(paste("protocol", type[1], sep = "_"))(object, file = file,
    append = append, ...)

#' @export
#' @rdname svSuiteData
protocol_text <- function(object, file = "", append = FALSE, ...)
  UseMethod("protocol_text")

#' @export
#' @rdname svSuiteData
protocol_text.svSuiteData <- function(object, file = "",
append = FALSE, ...) {
  if (!is.svSuiteData(object))
    stop("'object' must inherit from 'svSuiteData'")
  Tests <- sort(ls(object))
  if (length(Tests) == 0) {
    cat("No test records!\n", file = file, append = append)
  } else {
    # Print general information about the tests
    Stats <- stats(object)
    Tests <- rownames(Stats)  # To make sure we use the same!
    Timing <- .formatTime(sum(Stats$timing, na.rm = TRUE), secDigits = 1)
    cat("= A svUnit test suite", Timing, " with:\n\n", sep = "",
      file = file, append = append)
    cat(paste("* ", Tests, " ... ", as.character(Stats$kind), "",
      sep = "", collapse = "\n"),
      "\n\n", sep = "", file = file, append = TRUE)

    # Summarize each test
    for (Test in Tests)
      summary(object[[Test]], file = file, append = TRUE)
  }
}

#' @export
#' @rdname svSuiteData
protocol_junit <- function(object, ...)
  UseMethod("protocol_junit")

#' @export
#' @rdname svSuiteData
protocol_junit.svSuiteData <- function(object, file = "", append = FALSE, ...) {
  if (!is.svSuiteData(object))
    stop("'object' must inherit from 'svSuiteData'")
  #if(!require(XML, quietly = TRUE))
  #  return(invisible(FALSE))
  requireNamespace("XML")

  Tests <- sort(ls(object))
  if (length(Tests) > 0 && inherits(object[[Tests[1]]], "svSuiteData")) {
    # This is a set of suites (containing svSuiteData)
    root <- XML::xmlNode('testsuites')
  } else {
    # This is a single suite (containing svTestData)
    root <- XML::xmlNode('testsuite')
  }

  with(stats(object), addAttributes(root, name = NULL, tests = length(Tests),
    errors = sum(kind == '**ERROR**'), failures = sum(kind == '**FAILS**'),
    skip = sum(kind == 'DEACTIVATED')))
  for (Test in Tests)
    root <- XML::addChildren(root,
      kids = list(protocol_junit(object[[Test]], append = TRUE)))

  # Decide whether to return the xml node or write the xml file
  if (isTRUE(append)) {
    return(root)
  } else {
    XML::saveXML(root, file)
    return(invisible(TRUE))
  }
}
