\name{svTestData}
\alias{is.svTestData}
\alias{stats}
\alias{stats.svTestData}
\alias{print.svTestData}
\alias{summary.svTestData}

\title{ Objects of class 'svTestData' contain results from running a test }
\description{
  The 'svTestData' contains results of test run. The \code{checkxxx()} functions
  and the \code{runTest()} method generate one such object which is located in
  the \code{.Log} object in .GlobalEnv. It is then possible to display and
  report information it contains in various ways to analyze the results.
}

\usage{
is.svTestData(x)

stats(object, \dots)
\method{stats}{svTestData}(object, \dots)

\method{print}{svTestData}(x, all = FALSE, header = TRUE, file = "",
	append = FALSE, \dots)
\method{summary}{svTestData}(object, header = TRUE, file = "",
	append = FALSE, \dots)
}

\arguments{
  \item{x}{ any kind of object, or a 'svTestData' object in the case of
    \code{print}. }
  \item{object}{ a 'svTestData' object. }
  \item{all}{ do we print concise report for all test, or only for the tests
    that fail or produce an error? }
  \item{header}{ do we print a header or not? }
  \item{file}{ character. The path to the file where to write the report. If
    \code{file = ""}, the report is output to the console. }
  \item{append}{ do we append to this file? }
  \item{\dots}{ further arguments to pass to methods. Not used yet. }
}

\value{
  \code{is.svTestData()} returns \code{TRUE} if the object is an 'svTestData'.
  The various methods serve to extract or print content in the object.
}

\author{ Philippe Grosjean <phgrosjean@sciviews.org> }

\seealso{ \code{\link{svTest}}, \code{\link{svSuiteData}}, \code{\link{check}},
  \code{\link{Log}} }

\examples{
foo <- function(x, y = 2) return(x * y)
is.test(foo)  # No
## Create test cases for this function
test(foo) <- function () {
	checkEqualsNumeric(4, foo(2))
	checkEqualsNumeric(5, foo(2, 3))
	checkEqualsNumeric(5, foo(nonexists))
}
## Generate a 'svTestData' object by running the test
obj <- runTest(foo)  # Equivalent to runTest(test(foo)), but shorter
obj
summary(obj)
stats(obj)
is.svTestData(obj)

rm(foo, obj)
}

\keyword{ utilities }

\concept{ unit testing }
