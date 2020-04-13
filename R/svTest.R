#' Create, attach to and manipulate test functions in R objects
#'
#' Test functions are functions without arguments with class 'svTest' containing
#' one or more assertions using \code{checkxxx()} functions. They can be
#' attached to any object as a 'test' attribute. They can also be transferred
#' into a more formal test unit file on disk by applying the [makeUnit()] method.
#'
#' @param testFun A function without arguments defining assertions (using
#' `checkxxx()` functions) for tests to be transformed into a 'svTest' object.
#' @param x Any kind of object.
#' @param value The tests to place in the object (as 'test' attribute); could be
#' a 'svTest' object, or a function without arguments with
#' assertions (`checkxxx()` functions).
#' @param name The name of a test.
#' @param dir The directory where to create the test unit file.
#' @param objfile The path to the file containing the original source code of
#' the object being tested. This argument is used to bring a context for a test
#' and allow a GUI to automatically open the source file for edition when the
#' user clicks on a test that failed or raised an error.
#' @param codeSetUp An expression with some code you want to add to the
#' `.setUp()` function in your unit file (this function is executed before each
#' test.
#' @param codeTearDown An expression with some code you want to add to the
#' `.tearDown()` function in your unit file (this function is executed after
#' each test.
#' @param tag A tag is a character string identifying a location in source code
#' files (either a test unit file, or the original source code of the tested
#' objects defined in `objfile =`. This character string will be searched by the
#' text editor for easy location of the cursor near the corresponding test
#' command, or near the location in the original object that is concerned by
#' this test. Use any string you want to uniquely identify your tag, both in
#' your files, and in this argument.
#' @param msg A message you want to associate with this test run.
#' @param packageName A character string identifying the package from which to
#' extract examples.
#' @param manFilesDir A character string identifying the directory holding the
#' manual pages and examples.
#' @param skipFailing A logical indicating whether missing or failing
#' documentation examples should be marked as `skipped` instead of as `failure`.
#' @param  ... Further arguments to the method (not used yet).
#'
#' @return
#' A 'svTest' object for [svTest()], [as.svTest()] and [test()]. Function
#' [is.svTest()] returns `TRUE` if 'x' is a 'svTest' object, and `is.test()`
#' does the same but also looks in the 'test' attribute if the class of 'x' is
#' not 'svTest' and returns `TRUE` if it finds something there.
#'
#' [makeUnit()] takes an object, extract its test function and write it in a
#' sourceable test unit on the disk (it should be compatible with 'RUnit' test
#' unit files too).
#'
#' [runTest()] returns invisibly a 'svTestData' object with all results after running specified tests.
#'
#' @export
#' @author Philippe Grosjean
#' @seealso [svSuite()], [is.svTestData()], [Log()], [checkEquals()]
#' @keywords utilities
#' @concept unit testing
#' @examples
#' clearLog()    # Clear the log file
#'
#' foo <- function(x, y = 2)
#'   return(x * y)
#' is.test(foo)    # No
#' # Create test cases for this function
#' test(foo) <- function() {
#'   checkEqualsNumeric(4, foo(2))
#'   checkEqualsNumeric(6, foo(2, 3))
#'   checkTrue(is.test(foo))
#'   checkTrue(is.test(test(foo)))
#'   checkIdentical(attr(foo, "test"), test(foo))
#'   checkException(foo(2, "aa"))
#'   checkException(foo("bb"))
#' }
#' is.test(foo)    # Yes
#'
#' \dontrun{
#' # Create a test unit on disk and view it
#' unit <- makeUnit(foo)
#' file.show(unit, delete.file = TRUE)
#' }
#'
#' # Run the test
#' (runTest(foo))
#' # Same as...
#' bar <- test(foo)
#' (runTest(bar))
#'
#' # How fast can we run 100 times such kind of tests (700 test in total)?
#' # (just an indication because in real situation with test unit files, we
#' # have also the time required to source the units!)
#' system.time(for (i in 1:100) runTest(foo))[3]
#'
#' is.svTest(test(foo))    # Yes, of course!
#' # When an object without associated test is passed to runTest(),
#' # a simple test containing only a DEACTIVATED entry is build
#' x <- 1:10
#' summary(runTest(x))
#'
#' summary(Log())
#'
#' rm(foo, bar, x)
svTest <- function(testFun) {
  # Create a 'svTest' object, using testFun: a function without arguments
  # that contains one or more checkXX() assertions
  if (!is.function(testFun))
    stop("'testFun' must be a function or a 'svTest' object")
  # Check that there are no arguments
  if (length(formals(testFun)) > 0)
    stop("'testFun' must be a function without any arguments")
  # This is a S3 object of class 'svTest', subclassing 'function'
  class(testFun) <- c("svTest", "function")
  testFun
}

#' @export
#' @rdname svTest
print.svTest <- function(x, ...) {
  cat("svUnit test function:\n")
  print(body(x))
  invisible(x)
}

#' @export
#' @rdname svTest
as.svTest <- function(x) {
  # Coercion to a 'svTest' object
  svTest(x)
}

#' @export
#' @rdname svTest
is.svTest <- function(x) {
  # It this a svTest object
  inherits(x, "svTest")
}

#' @export
#' @rdname svTest
is.test <- function(x) {
  # Is this a 'svTest'object
  # or do this object contain a non NULL 'test' attribute?
  return(is.svTest(x) || !is.null(attr(x, "test")))
}

#' @export
#' @rdname svTest
test <- function(x) {
  # If x is a 'svTest' object, return it, otherwise,
  # get the 'test' attribute from the object, if it exists
  if (is.svTest(x)) {
    return(x)
  } else {
    res <- attr(x, "test")
    if (is.null(res)) {
      # Create a dummy test with only a DEACTIVATED entry
      res <- svTest(function() DEACTIVATED("Object has no tests!"))
    }
    return(res)
  }
}

#' @export
#' @rdname svTest
`test<-` <- function(x, value) {
  # Add 'value' as a 'test' attribute to 'x' after coercing it to 'svTest'
  attr(x, "test") <- as.svTest(value)
  x
}

#' @export
#' @rdname svTest
makeUnit <- function(x, ...)
  UseMethod("makeUnit")

#' @export
#' @rdname svTest
makeUnit.default <- function(x, name = make.names(deparse(substitute(x))),
dir = tempdir(), objfile = "", codeSetUp = NULL, codeTearDown = NULL, ...) {
  # Take an object and make a unit from the tests it contains
  # It is saved in a file runit<name>.R in 'dir'
  name <- as.character(name)[1]
  name <- sub("^test\\.(.+)\\.$", "\\1", name)
  # Under Windows, we transform \\ into /
  dir <- gsub("\\\\", "/", as.character(dir)[1])
  Unit <- .prepareUnit(name, dir)
  # Just get the test from the object
  Test <- test(x)
  # Make required initialisation to allow locating objects
  .writeSetUp(unit = Unit, file = objfile, code = codeSetUp)
  .writeTearDown(unit = Unit, code = codeTearDown)
  # Write the test function in the file
  .writeTest(unit = Unit, objname = name, obj = x)
  # Return the name of the test function
  Unit
}

#' @export
#' @rdname svTest
makeUnit.svTest <- function(x, name = make.names(deparse(substitute(x))),
dir = tempdir(), objfile = "", codeSetUp = NULL, codeTearDown = NULL, ...) {
  # I know: this is not needed, but it is there in case additional work
  # would be needed in the future, and also to show that makeUnit is
  # designed to work on 'svTest' objects
  makeUnit.default(x, name = name, dir = dir, objfile = objfile,
    codeSetUp = codeSetUp, codeTearDown = codeTearDown, ...)
}

#' @export
#' @rdname svTest
runTest <- function(x, ...)
  UseMethod("runTest")

#' @export
#' @rdname svTest
runTest.default <- function(x, name = deparse(substitute(x)), objfile = "",
tag = "", msg = "", ...) {
  # Run the test for the 'test' attribute of this object
  name <- paste("test(", name, ")", sep = "")
  runTest(test(x), name = name, objfile = objfile, tag = tag, msg = msg, ...)
}

#' @export
#' @rdname svTest
runTest.list <- function(x, ...) {
  # Run each test in x, giving each test the name it has in x
  lapply(names(x), function(name, item=x[[name]]) {
    unit <- ifelse(is.null(attr(item, "unit")), "**root**", attr(item, "unit"))
    runTest(item, name = name, unit = unit, ...)
  })
}

#' @export
#' @rdname svTest
runTest.svTest <- function(x, name = deparse(substitute(x)), objfile = "",
tag = "", msg = "", ...) {
  if (!is.svTest(x))
    stop("'x' must be a 'svTest' object")
  # Names of object and test
  test <- as.character(name)[1]
  test <- .runTest(x, test = test, objfile = objfile, tag = tag, msg = msg, ...)
  .Log <- Log()
  invisible(.Log[[test]])
}
