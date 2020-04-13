# Run tests using svUnit
# This is a wrapper to run these from within testthat
# so that RStudio's test function and devtools::test() can be used too
pkgname <- "svUnit"

test_svUnit <- function(pkgname) {
  library(svUnit)
  clearLog()

  # Current dir is /tests/testthat
  basedir <- dirname(dirname(getwd()))

  # Look for our tests in /unitTests or /inst/unitTests
  testdir <- file.path(basedir, "unitTests")
  if (!dir.exists(testdir)) {
    # We must be in a development environment, look at /inst/unitTests
    testdir <- file.path(basedir, "inst", "unitTests")
  }
  if (!dir.exists(testdir)) {
    # We must be in a checking environment, look at /<pkgname>/unitTests
    testdir <- file.path(basedir, pkgname, "unitTests")
  }
  if (!dir.exists(testdir)) {
    # No test directory found
    stop("No svUnit test directories found for ", basename(basedir))
  }

  res <- capture.output(runTest(svSuite(paste0("dir:", testdir)), pkgname))
  summary(Log())
}
test_svUnit(pkgname)
