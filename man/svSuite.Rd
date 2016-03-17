\name{svSuite}
\alias{svSuite}
\alias{as.svSuite}
\alias{is.svSuite}
\alias{svSuiteList}
\alias{print.svSuite}
\alias{makeUnit.svSuite}
\alias{runTest.svSuite}

\title{ Create and run test suites by collecting together unit tests and
  function tests defined in objects }
\description{
  A 'svSuite' object is essentially a list of test units directories (or
  packages, in this case, corresponding directories are PKG/unitTests and its
  subdirectories), and of object names containing tests to add temporarily to
  the test suite. These must be formatted in a concise way as described for the
  'tests' argument.

  \code{svSuiteList()} lists all loaded packages having /unitTests/runit*.R
  files (or similar files in subdirectories), and all objects in the user
  workspace that have a 'test' attribute, or are 'svTest' objects (by default).
  It is a rather exhaustive list of all test items currently available in the
  current R session, but restricted by \code{getOption("svUnit.excludeList")}.

  \code{makeUnit()} writes a test unit on disk with the tests from the objects
  lised in the 'svSuite' object that do not belong yet to a test unit.
  \code{runTest()} runs all the test in packages, directories and objects listed
  in the 'svSuite' object.
}

\usage{
svSuite(tests)

as.svSuite(x)
is.svSuite(x)

svSuiteList(packages = TRUE, objects = TRUE, dirs = getOption("svUnit.dirs"),
	excludeList = getOption("svUnit.excludeList"), pos = .GlobalEnv,
	loadPackages = FALSE)

\method{print}{svSuite}(x, \dots)
\method{makeUnit}{svSuite}(x, name = make.names(deparse(substitute(x))),
	dir = tempdir(), objfile = "", codeSetUp = NULL, codeTearDown = NULL,
	pos = .GlobalEnv, \dots)
\method{runTest}{svSuite}(x, name = make.names(deparse(substitute(x))),
    unitname = NULL, \dots)
}

\arguments{
  \item{tests}{ a character string with items to include in the test suite.
    It could be 'package:PKG' for including test units located in the /unitTests
	subdirectory of the package PGK, or 'package:PKG (SUITE)' for test units
	located in the subdirectory /unitTests/SUITE of package PKG, or 'dir:MYDIR'
	for including test units in MYDIR, or 'test(OBJ)' for tests embedded in an
	object, or 'OBJ' for 'svTest' object directly. }
  \item{x}{ any kind of object. }
  \item{packages}{ do we list test units available in loaded packages?
    Alternatively one can provide a character vector of package names, and it
	will be used to filter packages (take care: in this case it will look at
	installed packages, not only loaded packages)! }
  \item{objects}{ do we list test available in objects? Alternatively, one can
    provide a character vector of object names, and it will filter objects in
	'pos' according to this vector. }
  \item{dirs}{ an additional list of directories where to look for more test
    units. For convenience, this list can simply be saved as an 'svUnit.dirs'
	options. }
  \item{excludeList}{ a list of items to exclude from the listing. The function
    uses regular expression to match the exclusions. So, for instance, specifying
	\code{"package:MYPKG"} will exclude all items from package 'MYPKG', while
	using \code{"package:MYPKG$"} will exclude only tests suites defined in the
	.../MYPKG/unitTests directory, bur not in its subdirectories. For
    convenience, it can be saved in a 'svUnit.excludeList' option. By default,
	all tests for packages whose name start with 'sv' or 'RUnit' are excluded,
	that is, \code{c("package:sv", "package:RUnit")}. }
  \item{pos}{ the environment to look for 'objects' (environment, character
    string with name of an environment, or interger with position of the
	environment in the search path. }
  \item{loadPackages}{ in the case a list of packages is provided in
    \code{packages =}, do we make sure that these packages are loaded? If yes,
	the function will try to load all packages in that list that are not loaded
	yet and will issue a warning for the packages not found. Default,
	\code{FALSE}. }
  \item{name}{ the name of the test suite to build. }
  \item{dir}{ the directory where to create the test unit file }
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
  \item{unitname}{ the name of a unit to run inside the suite. If \code{NULL}
    (by default), all units are run. }
  \item{\dots}{ further arguments to pass to \code{makeUnit()} or
    \code{runTest()} (not used yet). }
}

\value{
  \code{svSuite()}, \code{as.svSuite()} and \code{svSuiteList} return a
  'svSuite' object. \code{is.svSuite()} returns \code{TRUE} if the object is an
  'svSuite'.

  \code{makeUnit()} creates a test unit file on disk, and \code{runTest()} run
  the tests in such a file. They are used for their side-effect, but the first
  one also returns the file created, and the second one returns invisibly the
  list of all test unit files that where sourced ans run.
}

\details{
  Thanks to the variety of sources allowed for tests, it is possible to define
  these tests in a structured way, inside packages, like for the 'RUnit'
  package (but with automatic recognition of test units associated to packages,
  in the present case). It is also easy to define tests more loosely by just
  attaching those tests to the objects you want to check. Whenever there objects
  are loaded in the user's workspace, their tests are available. In both cases,
  a test unit file on disk is sourced in a local environment and test functions
  are run (same approach as in the 'RUnit' package, and the same test unit files
  should be compatibles with both 'RUnit' and 'svUnit' packages), but in the
  case of a loosy definition of the tests by attachment to objects, the test
  unit file is created on the fly in the temporary directory (by default).

  At any time, you can transform a series of tests loosy attached to objects
  into a test unit file by applying \code{makeUnit()} to a 'svSuite' object,
  probably specifying another directory than the (default) temporary dir for
  more permanent storage of your test unit file. The best choice is the
  '/inst/unitTests' directory of a package source, or one of its subdirectories.
  That way, your test unit file(s) will be automatically listed and available
  each time you load the compiled package in R (if you list them using
  \code{svSuiteList()}). Of course, you still can exclude tests from given
  packages by adding 'package:PKG' in the exclusion list with something like:
  \code{options(svUnit.excludeList = c(getOption("svUnit.excludeList"), "package:PKG"))}.
}

\author{ Philippe Grosjean <phgrosjean@sciviews.org> }

\seealso{ \code{\link{svSuiteData}}, \code{\link{svTest}}, \code{\link{Log}},
  \code{\link{check}}, \code{\link[RUnit]{checkTrue}} }

\examples{
svSuiteList()	# List all currently available test units and test cases
## Exclusion list is used (regular expression filtering!). It contains:
(oex <- getOption("svUnit.excludeList"))
## Clear it, and relist available test units
options(svUnit.excludeList = NULL)
svSuiteList()

## Two functions that include their test cases
Square <- function(x) return(x^2)
test(Square) <- function() {
	checkEquals(9, Square(3))
	checkEquals(c(1, 4, 9), Square(1:3))
	checkException(Square("xx"))
}

Cube <- function(x) return(x^3)
test(Cube) <- function() {
	checkEquals(27, Cube(3))
	checkEquals(c(1, 8, 28), Cube(1:3))
	checkException(Cube("xx"))
}

## A separate test case object (not attached to a particular object)
## This is the simplest way to loosely define quick and durty integration tests
test_Integrate <- svTest(function() {
	checkTrue(1 < 2, "check1")
	v <- 1:3 	# The reference
	w <- 1:3 	# The value to compare to the reference
	checkEquals(v, w)
})

## A function without test cases (will be filtered out of the suite list)
foo <- function(x) return(x)

## Look now which tests are available
svSuiteList()

## Only objects, no package units
svSuiteList(packages = FALSE)

\dontrun{
## Create the test unit file for all objects with tests in .GlobalEnv
myunit <- makeUnit(svSuiteList(), name = "AllTests")
file.show(myunit, delete.file = TRUE)
}

## Filter objects using a list (object with/without tests and a nonexisting obj)
svSuiteList(packages = FALSE, objects = c("Cube", "foo", "bar"))

## Create another svSuite object with selected test items
(mysuite <- svSuite(c("package:svUnit (VirtualClass)", "test(Cube)")))
is.svSuite(mysuite)	# Should be!

\dontrun{
## Run all the tests currently available
(runTest(svSuiteList(), name = "AllTests"))
summary(Log())
}

## Restore previous exclusion list, and clean up the environment
options(svUnit.excludeList = oex)
rm(Square, Cube, foo, test_Integrate, mysuite, myunit, oex)
}

\keyword{ utilities }

\concept{ unit testing }
