\name{svTest}
\alias{svTest}
\alias{as.svTest}
\alias{is.svTest}
\alias{test}
\alias{test<-}
\alias{is.test}
\alias{print.svTest}
\alias{makeUnit}
\alias{makeTestListFromExamples}
\alias{makeUnit.default}
\alias{makeUnit.svTest}
\alias{runTest}
\alias{runTest.default}
\alias{runTest.svTest}
\alias{runTest.list}

\title{ Create, attach to and manipulate test functions in R objects }
\description{
  Test functions are functions without arguments with class 'svTest' containing
  one or more assertions using \code{checkxxx()} functions. They can
  be attached to any object as a 'test' attribute. They can also be transferred
  into a more formal test unit file on disk by applying the \code{makeUnit()}
  method.
}

\usage{
svTest(testFun)
as.svTest(x)
is.svTest(x)

test(x)
test(x) <- value
is.test(x)

\method{print}{svTest}(x, \dots)

makeUnit(x, \dots)
\method{makeUnit}{default}(x, name = make.names(deparse(substitute(x))),
	dir = tempdir(), objfile = "", codeSetUp = NULL, codeTearDown = NULL, \dots)
\method{makeUnit}{svTest}(x, name = make.names(deparse(substitute(x))),
	dir = tempdir(), objfile = "", codeSetUp = NULL, codeTearDown = NULL, \dots)

runTest(x, \dots)
\method{runTest}{default}(x, name = deparse(substitute(x)), objfile = "",
	tag = "", msg = "", \dots)
\method{runTest}{svTest}(x, name = deparse(substitute(x)), objfile = "",
	tag = "", msg = "", \dots)
\method{runTest}{list}(x, \dots)

makeTestListFromExamples(packageName, manFilesDir, skipFailing=FALSE)
}

\arguments{
  \item{testFun}{ a function without arguments defining assertions (using
    checkxxx() functions) for tests to be transformed into a 'svTest' object. }
  \item{x}{ any kind of object. }
  \item{value}{ the tests to place in the object (as 'test' attribute);
    could be a 'svTest' object, or a function without arguments with assertions
    (\code{checkxxx()} functions). }
  \item{name}{ the name of a test; }
  \item{dir}{ the directory where to create the test unit file. }
    \item{objfile}{ the path to the file containing the original source code of
    the object being tested. This argument is used to bring a context for a
    test and allow a GUI to automatically open the source file for edition when
    the user clicks on a test that failed or raised an error. }
  \item{codeSetUp}{ an expression with some code you want to add to the
    \code{.setUp() } function in your unit file (this function is executed
    before each test. }
  \item{codeTearDown}{ an expression with some code you want to add to the
    \code{.tearDown() } function in your unit file (this function is executed
    after each test. }
  \item{tag}{ a tag is a character string identifying a location in source code
    files (either a test unit file, or the original source code of the tested
    objects defined in \code{objfile}. This character string will be searched
    by the text editor for easy location of the cursor near the corresponding`
    test command, or near the location in the original object that is concerned
    by this test. Use any string you want to uniquely identify your tag, both
    in your files, and in this argument. }
  \item{msg}{ a message you want to associate with this test run. }
  \item{packageName}{ a character string identifying the package
    from which to extract examples. }
  \item{manFilesDir}{ a character string identifying the directory
    holding the manual pages and examples. }
  \item{skipFailing}{ a logical indicating whether missing or failing
    documentation examples should be marked as `skipped` instead of as
    `failure`. }
  \item{\dots}{ further arguments to the method (not used yet). }
}

\value{
  A 'svTest' object for \code{svTest()}, \code{as.svTest()}
  and \code{test()}. Function \code{is.svTest()} returns \code{TRUE} if 'x' is
  a 'svTest' object, and \code{is.test()} does the same but also looks in the
  'test' attribute if the class of 'x' is not 'svTest' and returns \code{TRUE}
  if it finds something there.

  \code{makeUnit()} takes an object, extract its test function and write it in
  a sourceable test unit on the disk (it should be compatible with 'RUnit' test
  unit files too).

  \code{runTest()} returns invisibly a 'svTestData' object with all results
  after running specified tests.
}

\author{ Philippe Grosjean <phgrosjean@sciviews.org> }

\seealso{ \code{\link{svSuite}}, \code{\link{is.svTestData}},
  \code{\link{check}}, \code{\link{Log}} }

\examples{
clearLog()	# Clear the log file

foo <- function(x, y = 2) return(x * y)
is.test(foo)	# No
## Create test cases for this function
test(foo) <- function () {
	checkEqualsNumeric(4, foo(2))
	checkEqualsNumeric(6, foo(2, 3))
	checkTrue(is.test(foo))
	checkTrue(is.test(test(foo)))
	checkIdentical(attr(foo, "test"), test(foo))
	checkException(foo(2, "aa"))
	checkException(foo("bb"))
}
is.test(foo)	# Yes

\dontrun{
## Create a test unit on disk and view it
unit <- makeUnit(foo)
file.show(unit, delete.file = TRUE)
}

## Run the test
(runTest(foo))
## Same as...
bar <- test(foo)
(runTest(bar))

## How fast can we run 100 times such kind of tests (700 test in total)?
## (just an indication because in real situation with test unit files, we
## have also the time required to source the units!)
system.time(for (i in 1:100) runTest(foo))[3]

is.svTest(test(foo))	# Yes, of course!
## When an object without associated test is passed to runTest(), a simple
## test containing only a DEACTIVATED entry is build
x <- 1:10
summary(runTest(x))

summary(Log())

rm(foo, bar, x)
}

\keyword{ utilities }

\concept{ unit testing }
