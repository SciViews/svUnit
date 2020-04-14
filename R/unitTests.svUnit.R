#' Unit tests for the package 'svUnit'
#'
#' Performs unit tests defined in this package by running
#' `example(unitTests.svUnit)`. Tests are in `runit*.R` files located in the
#' '/unitTests' subdirectory or one of its subdirectories ('/inst/unitTests' and
#' subdirectories in package sources).
#'
#' @name unitTests.svUnit
#' @author Philippe Grosjean
#' @keywords utilities
#' @examples
#' if (require(svUnit)) {
#'   clearLog()
#'   runTest(svSuite("package:svUnit"), "svUnit")
#'   \donttest{
#'   # Tests to run with example() but not with R CMD check
#'   runTest(svSuite("package:svUnit (VirtualClass)"), "VirtualClass")
#'   }
#'   \dontrun{
#'   # Tests to present in ?unitTests.svUnit but not run automatically
#'   # Run all currently loaded packages test cases and test suites
#'   runTest(svSuiteList(), "AllTests")
#'   }
#'   \dontshow{
#'   # Put here test units you want to run during R CMD check but
#'   # don't want to show or run with example(unitTests.svUnit)
#'   }
#'   # Check errors at the end (needed to interrupt R CMD check)
#'   errorLog()
#' }
NULL
