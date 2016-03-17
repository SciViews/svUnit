\name{svSuiteData}
\alias{svSuiteData}
\alias{is.svSuiteData}
\alias{stats.svSuiteData}
\alias{metadata}
\alias{metadata.svSuiteData}
\alias{print.svSuiteData}
\alias{summary.svSuiteData}
\alias{protocol}
\alias{protocol.default}
\alias{protocol.svSuiteData}
\alias{protocol_text}
\alias{protocol_text.svSuiteData}
\alias{protocol_junit}
\alias{protocol_junit.svSuiteData}
\alias{protocol_junit.svTestData}

\title{ Objects of class 'svSuiteData' contain results from running test suites }
\description{
  The 'svSuiteData' object contains results of all test run in one or more test
  suites. The \code{checkxxx()} functions and the \code{runTest()} method
  generate data (objects 'svTestData') contained in the default 'svSuiteData'
  named \code{.Log} and located in .GlobalEnv. It is then possible to display
  and report information it contains in various ways to analyze the results.
}

\usage{
is.svSuiteData(x)

\method{stats}{svSuiteData}(object, \dots)

metadata(object, \dots)
\method{metadata}{svSuiteData}(object, fields = c("R.version", "sessionInfo",
	"time", "description"), \dots)

\method{print}{svSuiteData}(x, all = FALSE, file = "", append = FALSE, \dots)

\method{summary}{svSuiteData}(object, ...)

protocol(object, type = "text", file = "", append = FALSE, \dots)
\method{protocol}{default}(object, type = "text", file = "", append = FALSE, \dots)
\method{protocol}{svSuiteData}(object, type = "text", file = "", append = FALSE, \dots)

protocol_text(object, file = "", append = FALSE, \dots)
\method{protocol_text}{svSuiteData}(object, file = "", append = FALSE, \dots)

protocol_junit(object, \dots)
\method{protocol_junit}{svSuiteData}(object, file = "", append = FALSE, \dots)
\method{protocol_junit}{svTestData}(object, \dots)
}

\arguments{
  \item{x}{ any kind of object, or a 'svSuiteData' object in the case of
    \code{print}. }
  \item{object}{ a 'svSuiteData' object. }
  \item{fields}{ character vector. The name of all metadata items you want to
    extract for the object. The default value is an exhaustive list of all
	available metadata (i.e., defined by default) in the object, but you
	can add more: just add a corresponding attribute to your object. }
  \item{all}{ do we print concise report for all test, or only for the tests
    that fail or produce an error? }
  \item{file}{ character. The path to the file where to write the report. If
    \code{file = ""}, the protocol report is output to the console }
  \item{append}{ do we append to this file? }
  \item{type}{ character. The type of protocol report to create. For the moment,
    only \code{type = "text"} and \code{type = "junit"} are supported,
    but further types (HTML, LaTeX, Wiki, etc.) will be provided later. }
  \item{\dots}{ further arguments to pass to methods. Not used yet. }
}

\value{
  \code{is.svSuiteData()} returns \code{TRUE} if the object is an 'svSuiteData'.
  The various methods serve to extract or print content in the object.
}

\details{
  A 'svSuiteData' is, indeed, an environment. The results for the various tests
  runs are in non hidden (i.e., names not starting with a dot) objects that are
  of class 'svTestData' in this environment. Various other objects that control
  the execution of the test, their context, etc. are contained as hidden objects
  with name starting with a dot. Note that using an environment instead of a
  list for this object allows for a call by reference instead of a usual call by
  value in R, when passing this object to a function. This property is largely
  exploited in all svUnit functions to make sure results of test runs are
  centralized in the same log ('svSuiteData' object).
}

\author{ Philippe Grosjean <phgrosjean@sciviews.org>; Mario Frasca for the junit
  protocol. }

\seealso{ \code{\link{svSuite}}, \code{\link{is.svTestData}},
  \code{\link{check}}, \code{\link{Log}} }

\examples{
clearLog()	# Clear any existing log

## Run some tests
checkTrue(1 < 2)
checkException(log("a"))
foo <- function(x, y = 2) return(x * y)
test(foo) <- function () {
    checkEqualsNumeric(4, foo(2))
    checkEqualsNumeric(6, foo(2, nonexisting))
    checkTrue(is.test(foo))
    warning("This is a warning")
    cat("Youhou from test!\n")  # Don't use, except for debugging!
    checkTrue(is.test(test(foo)))
    checkIdentical(attr(foo, "test"), test(foo))
    checkException(foo(2, nonexisting))
    #DEACTIVATED("My deactivation message")
    checkException(foo(2))  # This test fails
}
runTest(foo)

## Now inspect the log, which is a 'svSuiteData' object
is.svSuiteData(Log())
stats(Log())
metadata(Log())
Log()	# Print method
summary(Log())

\dontrun{
## To get a print of the test protocol on file, use:
protocol(Log(), type = "text", file = "RprofProtocol.out")
file.show("RprofProtocol.out")
unlink("RprofProtocol.out")
}

rm(foo)

\dontrun{
## Profiling of very simple test runs
library(utils)
createLog(description = "test profiling", deleteExisting = TRUE)
imax <- 3
jmax <- 100
l <- 50
Rprof()
for (i in 1:imax) {
	# Change the context for these tests
    .Log$..Test <- paste("Test", i, sep = "")
    .Log$..Tag <- paste("#", i, sep = "")
    res <- system.time({
        for (j in 1:jmax) checkTrue(i <= j, "My test")
    }, gcFirst = TRUE)[3]
    print(res)
    flush.console()
}
Rprof(NULL)
## Look at profile
summaryRprof()
unlink("Rprof.out")

## Look at the log
summary(Log())
}
}

\keyword{ utilities }

\concept{ unit testing }
