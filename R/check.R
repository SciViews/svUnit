#' SciViews-R Unit assertions (check functions)
#'
#' These functions define the assertions in test functions. They are designed to
#' check the result of some test calculation.
#'
#' @param target a target object as reference for comparison.
#' @param current An object created for comparison (not an S4 class object).
#' @param msg An optional (short!) message to document a test. This message is
#' stored in the log and printed in front of each test report.
#' @param tolerance numeric >= 0. A numeric check does not fail if differences
#' are smaller than 'tolerance'.
#' @param checkNames Flag, if `FALSE` the names attributes are set to `NULL` for
#' both `current` and `target` before performing the check.
#' @param expr Syntactically valid R expression which can be evaluated and must
#' return a logical vector (`TRUE`|`FALSE`). A named expression is also allowed
#' but the name is disregarded. In [checkException()], expr is supposed to
#' generate an error to pass the test.
#' @param silent Flag passed on to try, which determines if the error message
#' generated by the checked function is displayed at the R console. By default,
#' it is `FALSE`.
#' @param ... Optional arguments passed to [all.equal()] or
#' [all.equal.numeric()].
#'
#' @return
#' These function return `TRUE` if the test succeeds, `FALSE` if it fails,
#' possibly with a 'result' attribute containing more information about the
#' problem. This is very different from corresponding functions in 'RUnit' that
#' stop with an error in case of test failure. Consequently, current functions
#' do not require the complex evaluation framework designed in 'RUnit' for that
#' reason.
#'
#' @details
#' These check functions are equivalent to various methods of the class
#' junit.framework.Assert of Java junit framework. They should be
#' code-compatible with functions of same name in 'RUnit' 0.4.17, except
#' for [checkTrue()] that is vectorized here, but accept only a scalar result in
#' 'RUnit'. For scalar test, the behavior of the function is the same in both
#' packages.
#' See [svTest()] for examples of use of these functions in
#' actual test cases attached to R objects.
#' See also the note about S4 objects in the [RUnit::checkTrue()] online help of the
#' 'RUnit' package.
#'
#' @export
#' @name check
#' @author Written by Ph. Grosjean, inspired from the general design of the
#' 'RUnit' package by Thomas Konig, Klaus Junemann & Matthias Burger.
#' @seealso [svTest()], [Log()], [guiTestReport()], [RUnit::checkTrue]
#' @keywords utilities
#' @concept unit testing
#' @examples
#' clearLog()     # Clear the svUnit log
#'
#' # All these tests are correct
#' (checkEquals(c("A", "B", "C"), LETTERS[1:3]))
#' (checkEqualsNumeric(1:10, seq(1, 10)))
#' (checkIdentical(iris[1:50, ], iris[iris$Species == "setosa",]))
#' (checkTrue(1 < 2))
#' (checkException(log("a")))
#' Log()    # See what's recorded in the log
#'
#' # ... but these ones fail
#' (checkEquals("A", LETTERS[1:3]))
#' (checkEqualsNumeric(2:11, seq(1, 10)))
#' (checkIdentical(iris[1:49, ], iris[iris$Species == "setosa",]))
#' (checkTrue(1 > 2))
#' (checkException(log(1)))
#' Log()    # See what's recorded in the log
#'
#' # Create a test function and run it
#' foo <- function(x, y = 2)
#'   return(x * y)
#' test(foo) <- function() {
#'   #DEACTIVATED()
#'   checkEqualsNumeric(5, foo(2))
#'   checkEqualsNumeric(6, foo(2, 3))
#'   checkTrue(is.test(foo))
#'   checkTrue(is.test(test(foo)))
#'   checkIdentical(test(foo), attr(foo, "test"))
#'   checkException(foo("b"))
#'   checkException(foo(2, "a"))
#' }
#' (runTest(foo))
#'
#' # Of course, everything is recorded in the log
#' Log()
#'
#' clearLog()
checkEquals <- function(target, current, msg = "",
tolerance = .Machine$double.eps^0.5, checkNames = TRUE, ...) {
  val <- FALSE
  timing <- as.numeric(system.time({
    ret <- try({
      # Run the test
      if (isTRUE(checkNames)) {
        cn <- ""	# Since this is the default value
      } else {
        cn <- ", checkNames = FALSE"
        names(target) <- NULL
        names(current) <- NULL
      }
      if (!is.numeric(tolerance))
        stop("tolerance has to be a numeric value")
      if (length(tolerance) != 1)
        stop("tolerance has to be a scalar")
      res <- all.equal(target, current, tolerance = tolerance, ...)
      val <- isTRUE(res)
    }, silent = TRUE)
  }, gcFirst = FALSE)[3])

  # Log this test
  test <- .logTest(timing)

  # Decide if recording more info or not
  minTiming <- getOption("svUnit.minTiming")
  if (is.null(minTiming))
    minTiming <- 0.1
  if (!isTRUE(getOption("svUnit.recordAll"))  && isTRUE(timing < minTiming)
    && val)
    return(invisible(TRUE))

  # Check for error
  if (inherits(ret, "try-error")) {
    val <- NA
    .logTestData(test, msg = msg, call =
    deparse(sys.call()[1:3], nlines = 1), timing = timing, val = -1,
      res = as.character(ret))
  } else {
    .logTestData(test, msg = msg, call =
      deparse(sys.call()[1:3], nlines = 1), timing = timing, val = val,
      res = if (val) "" else paste(c(res, .formatResult(current)),
      collapse = "\n"))
  }
  invisible(val)
}

#' @export
#' @rdname check
checkEqualsNumeric <- function(target, current, msg = "",
tolerance = .Machine$double.eps^0.5, ...) {
  val <- FALSE
  timing <- as.numeric(system.time({
    ret <- try({
      # Run the test
      if (!is.numeric(tolerance))
        stop("tolerance has to be a numeric value")
      if (length(tolerance) != 1)
        stop("tolerance has to be a scalar")
      res <- all.equal.numeric(as.vector(target), as.vector(current),
        tolerance = tolerance, ...)
      val <- isTRUE(res)
    }, silent = TRUE)
  }, gcFirst = FALSE)[3])

  # Log this test
  test <- .logTest(timing)

  # Decide if recording more info or not
  minTiming <- getOption("svUnit.minTiming")
  if (is.null(minTiming))
    minTiming <- 0.1
  if (!isTRUE(getOption("svUnit.recordAll"))  && isTRUE(timing < minTiming)
    && val)
    return(invisible(TRUE))

  # Check for error
  if (inherits(ret, "try-error")) {
    val <- NA
    .logTestData(test, msg = msg, call =
      deparse(sys.call()[1:3], nlines = 1), timing = timing, val = -1,
      res = as.character(ret))
  } else {
    .logTestData(test, msg = msg, call =
      deparse(sys.call()[1:3], nlines = 1), timing = timing, val = val,
      res = if (val) "" else paste(c(res, .formatResult(current)),
      collapse = "\n"))
  }
  invisible(val)
}

#' @export
#' @rdname check
checkIdentical <- function(target, current, msg = "") {
  val <- FALSE
  timing <- as.numeric(system.time({
    ret <- try({
      # Run the test
      val <- identical(target, current)
    }, silent = TRUE)
  }, gcFirst = FALSE)[3])

  # Log this test
  test <- .logTest(timing)

  # Decide if recording more info or not
  minTiming <- getOption("svUnit.minTiming")
  if (is.null(minTiming))
    minTiming <- 0.1
  if (!isTRUE(getOption("svUnit.recordAll"))  && isTRUE(timing < minTiming)
    && val)
    return(invisible(TRUE))

  # Check for error
  if (inherits(ret, "try-error")) {
    val <- NA
    .logTestData(test, msg = msg, call =
      deparse(sys.call()[1:3], nlines = 1), timing = timing, val = -1,
      res = as.character(ret))
  } else {
    .logTestData(test, msg = msg, call =
      deparse(sys.call()[1:3], nlines = 1), timing = timing, val = val,
      res = .formatResult(current))
  }
  invisible(val)
}

#' @export
#' @rdname check
checkTrue <- function(expr, msg = "") {
  val <- FALSE
  timing <- as.numeric(system.time({
    ret <- try({
      # Run the test
      val <- isTRUE(all(expr == TRUE))
    }, silent = TRUE)
  }, gcFirst = FALSE)[3])

  # Log this test
  test <- .logTest(timing)

  # Decide if recording more info or not
  minTiming <- getOption("svUnit.minTiming")
  if (is.null(minTiming))
    minTiming <- 0.1
  if (!isTRUE(getOption("svUnit.recordAll"))  && isTRUE(timing < minTiming)
    && val)
    return(invisible(TRUE))

  # Get call, without msg
  call <- sys.call()
  call <- deparse(call[names(call) != "msg"])

  # Check for error
  if (inherits(ret, "try-error")) {
    val <- NA
    .logTestData(test, msg = msg, call =
      deparse(sys.call()[1:2], nlines = 1), timing = timing, val = -1,
      res = as.character(ret))
  } else {
    .logTestData(test, msg = msg, call =
      deparse(sys.call()[1:2], nlines = 1), timing = timing, val = val,
      res = .formatResult(expr))
  }
  invisible(val)
}

#' @export
#' @rdname check
checkException <- function(expr, msg = "",
silent = getOption("svUnit.silentException")) {
  val <- FALSE
  timing <- as.numeric(system.time({
    ret <- try({
      # Run the test
      silent <- (is.null(silent) || isTRUE(silent))
      val <- inherits(res <- try(expr, silent = silent), "try-error")
    }, silent = TRUE)
  }, gcFirst = FALSE)[3])

  # Log this test
  test <- .logTest(timing)

  # Decide if recording more info or not
  minTiming <- getOption("svUnit.minTiming")
  if (is.null(minTiming))
    minTiming <- 0.1
  if (!isTRUE(getOption("svUnit.recordAll"))  && isTRUE(timing < minTiming)
    && val)
    return(invisible(TRUE))

  # Check for error
  if (inherits(ret, "try-error")) {
    val <- NA
    .logTestData(test, msg = msg, call =
      deparse(sys.call()[1:2], nlines = 1), timing = timing, val = -1,
      res = as.character(ret))
  } else {
    .logTestData(test, msg = msg, call =
      deparse(sys.call()[1:2], nlines = 1), timing = timing, val = val,
      res = if (val) paste(res, collapse = "\n") else
      "No exception generated!\n")
  }
  invisible(val)
}

#' @export
#' @rdname check
DEACTIVATED <- function(msg = "")
  stop(msg)
