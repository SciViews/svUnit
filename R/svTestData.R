#' Objects of class 'svTestData' contain results from running a test
#'
#' The 'svTestData' contains results of test run. The `checkxxx()` functions and
#' the `runTest()` method generate one such object which is located in the
#' `.Log` object in `.GlobalEnv`. It is then possible to display and report
#' information it contains in various ways to analyze the results.
#'
#' @param x Any kind of object, or a 'svTestData' object in the case of
#' [print()].
#' @param object A 'svTestData' object.
#' @param all Do we print concise report for all test, or only for the tests
#' that fail or produce an error?
#' @param header Do we print a header or not?
#' @param file Character. The path to the file where to write the report. If
#' `file = ""`, the report is output to the console.
#' @param append Do we append to this file?
#' @param ... Further arguments to pass to methods. Not used yet.
#'
#' @return
#' [is.svTestData()] returns `TRUE` if the object is an 'svTestData'. The
#' various methods serve to extract or print content in the object.
#'
#' @export
#' @name svTestData
#' @author Philippe Grosjean
#' @seealso [svTest()], [is.svSuiteData()], [Log()], [checkEquals()]
#' @keywords utilities
#' @concept unit testing
#' @examples
#' foo <- function(x, y = 2)
#'   return(x * y)
#' is.test(foo)  # No
#' # Create test cases for this function
#' test(foo) <- function() {
#'   checkEqualsNumeric(4, foo(2))
#'   checkEqualsNumeric(5, foo(2, 3))
#'   checkEqualsNumeric(5, foo(nonexists))
#' }
#' # Generate a 'svTestData' object by running the test
#' obj <- runTest(foo)  # Equivalent to runTest(test(foo)), but shorter
#' obj
#' summary(obj)
#' stats(obj)
#' is.svTestData(obj)
#'
#' rm(foo, obj)
is.svTestData <- function(x) {
  # It this a svTestData object
  inherits(x, "svTestData")
}

#' @export
#' @rdname svTestData
stats <- function(object, ...)
  UseMethod("stats")

#' @export
#' @rdname svTestData
stats.svTestData <- function(object, ...) {
  if (!is.svTestData(object))
    stop("'object' must inherit from 'svTestData'")
  Stats <- attr(object, "stats")
  Table <- table(object$kind)
  # Update the table with the total number of test
  Kinds <- c(Stats["tests"] - sum(Table[2:4], na.rm = TRUE), Table[2:4])
  names(Kinds) <- names(Table)
  # Return a list with the table of kinds and the total timing
  list(kind = Kinds, timing = Stats["timing"])
}

#' @export
#' @rdname svTestData
print.svTestData <- function(x, all = FALSE, header = TRUE, file = "",
append = FALSE, ...) {
  # If there is a context attribute, print info about the tests
  cat("", file = file, append = append)
  Context <- attr(x, "context")
  if (!is.null(Context)) {
    unitStr <- if (Context["unit"] == "") "" else
      paste(" (in ", basename(Context["unit"]), ")", sep = "")
    Stats <- stats(x)
    if (isTRUE(header)) {
      cat("\n== ", Context["test"], unitStr, .formatTime(Stats$timing,
        secDigits = 1), ": ", as.character(.kindMax(x$kind)), "\n",
        Context["msg"], "\n", sep = "", file = file, append = TRUE)
    }
    cat(paste(c("//Pass:", "Fail:", "Errors:"), Stats$kind[1:3],
      collapse = " "), "//\n\n", sep = "", file = file, append = TRUE)
    # Don't print tests that succeed if !all
    if (!isTRUE(all)) {
      X <- x[x$kind != "OK", ]
    } else {
      X <- x
    }
  } else {
    X <- x
  }
  # Print info about each individual filtered test
  if (nrow(X) > 0) {
    Res <- ifelse(X$res == "", "", paste("\n", X$res, sep = ""))
    cat(paste("* ", X$msg, ": ", X$call, .formatTime(X$timing,
      secDigits = 3), " ... ", as.character(X$kind), Res, sep = "",
      collapse = "\n"), file = file, append = TRUE)
  }
  invisible(x)
}

#' @export
#' @rdname svTestData
summary.svTestData <- function(object, header = TRUE, file = "",
append = FALSE, ...) {
  # If there is a context attribute, print info about the tests
  cat("", file = file, append = append)
  Context <- attr(object, "context")
  if (!is.null(Context)) {
    unitStr <- if (Context["unit"] == "") "" else
      paste(" (in ", basename(Context["unit"]), ")", sep = "")
    Stats <- stats(object)
    if (isTRUE(header)) {
      cat("\n== ", Context["test"], unitStr, .formatTime(Stats$timing,
          secDigits = 1), ": ", as.character(.kindMax(object$kind)), "\n",
          Context["msg"], "\n", sep = "", file = file, append = TRUE)
    }
    cat(paste(c("//Pass:", "Fail:", "Errors:"), Stats$kind[1:3],
      collapse = " "), "//\n\n", sep = "", file = file, append = TRUE)
  }
  # List tests that failed
  Items <- rownames(object)
  Fail <- object$kind == "**FAILS**"
  if (any(Fail)) {
    cat("=== Failures\n", file = file, append = TRUE)
    cat(paste("[", Items[Fail], "] ", object$msg[Fail], ": ",
      object$call[Fail], collapse = "\n", sep = ""), "\n\n",
      sep = "", file = file, append = TRUE)
  }
  # List tests that produce errors
  Err <- object$kind == "**ERROR**"
  if (any(Err)) {
    cat("=== Errors\n", file = file, append = TRUE)
    cat(paste("[", Items[Err], "] ", object$msg[Err], ": ",
      object$call[Err], collapse = "\n", sep = ""), "\n\n",
      sep = "", file = file, append = TRUE)
  }
}

#' @export
#' @rdname svTestData
protocol_junit.svTestData <- function(object, ...) {
  #if (!require(XML, quietly = TRUE))
  #  return(invisible(FALSE))
  requireNamespace("XML")

  toValidXmlString <- function(s) {
    s <- gsub("&", "&amp;", s)
    s <- gsub("<", "&lt;", s)
    s <- gsub(">", "&gt;", s)
    s <- gsub('"', "&quot;", s)
    s <- gsub("'", "&apos;", s)
    s
  }

  basename <- function(s)
    sub(".*/", "", s)

  Context <- attr(object, "context")
  Stats <- attr(object, "stats")
  .xmlNode <- XML::xmlNode
  .addChildren <- XML::addChildren
  result <- .xmlNode('testcase', attrs = c(
    'classname' = basename(Context[['unit']]),
    'name' = toValidXmlString(Context[['test']]),
    'time' = object$timing))
  kind <- as.numeric(.kindMax(object$kind))  # TODO: use accessor
  elementName <- c(NA, 'failure', 'error', NA)[kind]
  if (!is.na(elementName)) {
    failureNode <- .xmlNode(elementName, attrs = c(
      'type' = elementName,
      'message' = toValidXmlString(object$res)))  # TODO: use accessor
    result <- .addChildren(result, kids = list(failureNode))
  }
  if (kind == 4)
    result <- .addChildren(result, kids = list(.xmlNode('skipped')))

  result
}
