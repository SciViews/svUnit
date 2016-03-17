\name{Log}
\alias{Log}
\alias{createLog}
\alias{clearLog}
\alias{errorLog}
\alias{lastTest}
\alias{lastSuite}

\title{ SciViews R log management functions }
\description{
  These functions define the code of test functions. They are designed to check
  the result of some test calculation.
}

\usage{
Log(description = NULL)
createLog(description = NULL, deleteExisting = FALSE)
clearLog()
errorLog(stopit = TRUE, summarize = TRUE)
lastTest()
lastSuite()
}

\arguments{
  \item{description}{ a (short) character string describing this test suite
    log. }
  \item{deleteExisting}{ do we delete an existing a \code{.Log} object already
    defined in \code{.GlobalEnv} (no, by default)? }
  \item{stopit}{ do we issue an error (\code{stop()} in case of any error or
    failure? This is particularly useful if you want to interrupt R CMD check
	on packages, when you included one or more test suites in examples (see
	\code{?unitTests}. }
  \item{summarize}{	should the summary of the log be printed in case we stop
    execution of the code when an error is found (see \code{stopit} argument.
	It is, indeed, useful to indicate at this time which tests failed or raised
	an error. So, this argument should usually be left at its default value. }
}

\value{
  \code{Log()} and \code{createLog()} return the .Log object defined in
  .GlobalEnv by reference (it is indeed an environment). So, you can use its
  content (and change it, if you write functions to manipulate this log).

  \code{clearLog()} return invisibly TRUE or FALSE, depending if an existing
  log object was deleted or not.

  \code{errorLog()} is mainly used for its side-effect of stopping code
  execution and/or printing a summmary of the test runs in the context of
  example massaging in R CMD check (see the \"Writing R extensions\" manual).
  However, this function also returns invisibly a contingency table with the
  number of successes, failures, errors and deactivated tests recorded so far.

  \code{lastTest()} and \code{lastSuite()} recall results of last test and last
  suite run, respectively.
}

\details{
  svUnit records results of assertions (using the checkxxx() functions) in a
  'svSuiteData' object named \code{.Log} and located in .GlobalEnv. Hence, this
  log is easy to access. However, in order to avoid errors in your code in case
  this object was deleted, or not created, it is better to access it using
  \code{Log()} which take care to create the object if it is missing.
}

\author{ Philippe Grosjean <phgrosjean@sciviews.org> }

\seealso{ \code{\link{svSuiteData}}, \code{\link{svSuite}},
  \code{\link{svTest}}, \code{\link{check}} }

\examples{
clearLog()			# Clear the svUnit log

## Two correct tests
(checkTrue(1 < 2))
(checkException(log("a")))
errorLog()			# Nothing, because there is no error

\dontrun{
(checkTrue(1 > 2))	# This test fails
lastTest()			# Print results of last test
errorLog()			# Stop and summarize the tests run so far
}

clearLog()
}

\keyword{ utilities }

\concept{ unit testing }
