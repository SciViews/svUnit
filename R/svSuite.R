#' Create and run test suites by collecting together unit tests and function
#' tests defined in objects
#'
#' A 'svSuite' object is essentially a list of test units directories (or
#' packages, in this case, corresponding directories are PKG/unitTests and its
#' subdirectories), and of object names containing tests to add temporarily to
#' the test suite. These must be formatted in a concise way as described for the
#' 'tests' argument.
#'
#' [svSuiteList()] lists all loaded packages having /unitTests/runit*.R files
#' (or similar files in subdirectories), and all objects in the user workspace
#' that have a 'test' attribute, or are 'svTest' objects (by default). It is a
#' rather exhaustive list of all test items currently available in the current R
#' session, but restricted by `getOption("svUnit.excludeList")`.
#'
#' [makeUnit()] writes a test unit on disk with the tests from the objects
#' listed in the 'svSuite' object that do not belong yet to a test unit.
#' [runTest()] runs all the test in packages, directories and objects listed in
#' the 'svSuite' object.
#'
#' @param tests A character string with items to include in the test suite. It
#' could be 'package:PKG' for including test units located in the /unitTests
#' subdirectory of the package PGK, or 'package:PKG (SUITE)' for test units
#' located in the subdirectory /unitTests/SUITE of package PKG, or 'dir:MYDIR'
#' for including test units in MYDIR, or 'test(OBJ)' for tests embedded in an
#' object, or 'OBJ' for 'svTest' object directly.
#' @param x Any kind of object.
#' @param packages Do we list test units available in loaded packages?
#' Alternatively one can provide a character vector of package names, and it
#' will be used to filter packages (take care: in this case it will look at
#' installed packages, not only loaded packages)!
#' @param objects Do we list test available in objects? Alternatively, one can
#' provide a character vector of object names, and it will filter objects in
#' 'pos' according to this vector.
#' @param dirs An additional list of directories where to look for more test
#' units. For convenience, this list can simply be saved as an 'svUnit.dirs'
#' options.
#' @param excludeList A list of items to exclude from the listing. The function
#' uses regular expression to match the exclusions. So, for instance, specifying
#' `"package:MYPKG"` will exclude all items from package 'MYPKG', while using
#' `"package:MYPKG$"` will exclude only tests suites defined in the
#' .../MYPKG/unitTests directory, bur not in its subdirectories. For
#' convenience, it can be saved in a 'svUnit.excludeList' option. By default,
#' all tests for packages whose name start with 'sv' or 'RUnit' are excluded,
#' that is, `c("package:sv", "package:RUnit")`.
#' @param pos The environment to look for 'objects' (environment, character
#' string with name of an environment, or integer with position of the
#' environment in the search path.
#' @param loadPackages In the case a list of packages is provided in
#' `packages =`, do we make sure that these packages are loaded? If yes, the
#' function will try to load all packages in that list that are not loaded yet
#' and will issue a warning for the packages not found. Default, `FALSE`.
#' @param name The name of the test suite to build.
#' @param dir The directory where to create the test unit file.
#' @param objfile The path to the file containing the original source code of
#' the object being tested. This argument is used to bring a context for a
#' test and allow a GUI to automatically open the source file for edition when
#' the user clicks on a test that failed or raised an error.
#' @param codeSetUp An expression with some code you want to add to the
#' `.setUp()` function in your unit file (this function is executed before each
#' test.
#' @param codeTearDown An expression with some code you want to add to the
#' `.tearDown()` function in your unit file (this function is executed after
#' each test.
#' @param unitname The name of a unit to run inside the suite. If `NULL` (by
#' default), all units are run.
#' @param ... Further arguments to pass to [makeUnit()] or [runTest()] (not used
#' yet).
#'
#' @return
#' [svSuite()], [as.svSuite()] and [svSuiteList()] return a 'svSuite' object.
#' [is.svSuite()] returns `TRUE` if the object is an 'svSuite'.
#'
#' [makeUnit()] creates a test unit file on disk, and [runTest()] runs the tests
#' in such a file. They are used for their side-effect, but the first one also
#' returns the file created, and the second one returns invisibly the list of
#' all test unit files that where sourced ans run.
#'
#' @details
#' Thanks to the variety of sources allowed for tests, it is possible to define
#' these tests in a structured way, inside packages, like for the 'RUnit'
#' package (but with automatic recognition of test units associated to packages,
#' in the present case). It is also easy to define tests more loosely by just
#' attaching those tests to the objects you want to check. Whenever there objects
#' are loaded in the user's workspace, their tests are available. In both cases,
#' a test unit file on disk is sourced in a local environment and test functions
#' are run (same approach as in the 'RUnit' package, and the same test unit files
#' should be compatibles with both 'RUnit' and 'svUnit' packages), but in the
#' case of a loosely definition of the tests by attachment to objects, the test
#' unit file is created on the fly in the temporary directory (by default).
#'
#' At any time, you can transform a series of tests loosely attached to objects
#' into a test unit file by applying [makeUnit()] to a 'svSuite' object,
#' probably specifying another directory than the (default) temporary dir for
#' more permanent storage of your test unit file. The best choice is the
#' '/inst/unitTests' directory of a package source, or one of its
#' subdirectories. That way, your test unit file(s) will be automatically listed
#' and available each time you load the compiled package in R (if you list them
#' using [svSuiteList()]). Of course, you still can exclude tests from given
#' packages by adding 'package:PKG' in the exclusion list with something
#' like: `options(svUnit.excludeList = c(getOption("svUnit.excludeList"), "package:PKG"))`.
#'
#' @export
#' @author Philippe Grosjean
#' @seealso [svSuiteData()], [svTest()], [Log()], [checkEquals()], [RUnit::checkEquals()]
#' @keywords utilities
#' @concept unit testing
#' @examples
#' svSuiteList() # List all currently available test units and test cases
#' # Exclusion list is used (regular expression filtering!). It contains:
#' (oex <- getOption("svUnit.excludeList"))
#' # Clear it, and relist available test units
#' options(svUnit.excludeList = NULL)
#' svSuiteList()
#'
#' # Two functions that include their test cases
#' Square <- function(x)
#'   return(x^2)
#' test(Square) <- function() {
#'   checkEquals(9, Square(3))
#'   checkEquals(c(1, 4, 9), Square(1:3))
#'   checkException(Square("xx"))
#' }
#'
#' Cube <- function(x)
#'   return(x^3)
#' test(Cube) <- function() {
#'   checkEquals(27, Cube(3))
#'   checkEquals(c(1, 8, 28), Cube(1:3))
#'   checkException(Cube("xx"))
#' }
#'
#' # A separate test case object (not attached to a particular object)
#' # This is the simplest way to define quick and durty integration tests
#' test_Integrate <- svTest(function() {
#'   checkTrue(1 < 2, "check1")
#'   v <- 1:3 	# The reference
#'   w <- 1:3 	# The value to compare to the reference
#'   checkEquals(v, w)
#' })
#'
#' # A function without test cases (will be filtered out of the suite list)
#' foo <- function(x)
#'   return(x)
#'
#' # Look now which tests are available
#' svSuiteList()
#'
#' # Only objects, no package units
#' svSuiteList(packages = FALSE)
#'
#' \dontrun{
#' # Create the test unit file for all objects with tests in .GlobalEnv
#' myunit <- makeUnit(svSuiteList(), name = "AllTests")
#' file.show(myunit, delete.file = TRUE)
#' }
#'
#' # Filter objects using a list (object with/without tests and a nonexisting obj)
#' svSuiteList(packages = FALSE, objects = c("Cube", "foo", "bar"))
#'
#' # Create another svSuite object with selected test items
#' (mysuite <- svSuite(c("package:svUnit (VirtualClass)", "test(Cube)")))
#' is.svSuite(mysuite)	# Should be!
#'
#' \dontrun{
#' # Run all the tests currently available
#' (runTest(svSuiteList(), name = "AllTests"))
#' summary(Log())
#' }
#'
#' # Restore previous exclusion list, and clean up the environment
#' options(svUnit.excludeList = oex)
#' rm(Square, Cube, foo, test_Integrate, mysuite, myunit, oex)
svSuite <- function(tests) {
  # Check provided tests and build a 'svSuite' object
  tests <- as.character(tests)
  # Remove NAs and empty strings ("") from tests
  tests <- tests[!is.na(tests) & !(tests == "")]
  if (length(tests) > 0) {
    # Tests must be character strings like:
    # * package:PKG
    # * package:PKG (TESTSUITE)
    # * dir:MYDIR
    ## * test(OBJ) where OBJ is any object with a 'test' attribute
    # * OBJ being a 'svTest' object (with non "exotic" name!),
    # Syntax is checked, but not existence/validity of corresponding tests!
    check1 <- (regexpr("^package:[a-zA-Z][a-zA-Z._0-9]*$", tests) > -1)
    check2 <- (regexpr("^package:[a-zA-Z][a-zA-Z._0-9]* *\\(.+\\)$",
      tests) > -1)
    check3 <- (regexpr("^dir:.+", tests) > -1)
    check4 <- (regexpr("^test\\(.+\\)$", tests) > -1)
    check5 <- (regexpr("^[a-zA-Z0-9_.]+$", tests) > -1)
    wrong <- ((check1 + check2 + check3 + check4 + check5) == 0)
    if (any(wrong))
      stop("Wrong 'tests' data: must be 'package:PKG', 'package:PKG (SUITE)',\n'dir:MYDIR', 'test(OBJ)' or 'OBJ'")
  }
  # This is a 'svSuite' object subclassing 'character'
  class(tests) <- c("svSuite", "character")
  tests
}

#' @export
#' @rdname svSuite
as.svSuite <- function(x)
  svSuite(x)

#' @export
#' @rdname svSuite
is.svSuite <- function(x)
  inherits(x, "svSuite")

#' @export
#' @rdname svSuite
print.svSuite <- function(x, ...) {
  if (!is.svSuite(x))
    stop("'x' must be a 'svSuite' object")
  if (length(x) < 1) {
    cat("An empty svUnit test suite\n")
  } else {
    cat("A svUnit test suite definition with:\n")
    # Separate unit tests from tests embedded in objects
    isSuite <- regexpr("^[package:|dir:]", x) > -1
    if (any(isSuite)) {
      Suites <- x[isSuite]
      msg <- ifelse(length(Suites) == 1, "\n- Test suite:\n",
        "\n- Test suites:\n")
      cat(msg)
      print(Suites)
    }

    if (any(!isSuite)) {
      Objs <- x[!isSuite]
      msg <- ifelse(length(Objs) == 1, "\n- Test function:\n",
        "\n- Test functions:\n")
      cat(msg)
      print(Objs)
    }
  }
  invisible(x)
}

#' @export
#' @rdname svSuite
svSuiteList <- function(packages = TRUE, objects = TRUE,
dirs = getOption("svUnit.dirs"), excludeList = getOption("svUnit.excludeList"),
pos = .GlobalEnv, loadPackages = FALSE) {
  # List unit test (1) in loaded packages (2) in objects in pos and (3) in
  # directories, possibly filtering them using an exclusion list
  # Note: Komodo should list test unit files in loaded projects too!
  if (length(packages) < 1)
    stop("'package' cannot have zero length")
  if (length(objects) < 1)
    stop("'objects' cannot have zero length")

  items <- character()

  # 1) Unit test files in loaded packages
  if (packages[1] != FALSE) {
    if (is.character(packages)) {# We assume it is a list of packages
      Pkgs <- packages
    } else {# We use the list of all loaded packages
      Pkgs <- .packages()
    }
    for (Pkg in Pkgs) {
      # Look for test units in the package
      path <- system.file(package = Pkg, "unitTests")
      if (path != "" && file.info(path)$isdir) {
        pkgname <- paste("package", Pkg, sep = ":")
        items <- c(items, pkgname)
        Files <- list.files(path = path, full.names = TRUE)
        for (File in Files) {# Add all subdirectories too
          if (file.info(File)$isdir)
            items <- c(items, paste(pkgname, " (", basename(File),
              ")", sep = ""))
        }
      }
    }
  }

  # 2) Tests embedded in objects located in 'pos' environment
  if (objects[1] != FALSE) {
    envir = as.environment(pos)
    if (is.character(objects)) {
      tests <- character()
      for (Oname in objects) {
        if (exists(Oname, envir = envir, inherits = FALSE)) {
          Obj <- get(Oname, envir = envir, inherits = FALSE)
          if (is.svTest(Obj)) {
            tests <- c(tests, Oname)
          } else if (is.test(Obj)) {
            tests <- c(tests, paste("test(", Oname, ")", sep = ""))
          }
        }
      }
    } else {# We list all objects in pos
      Objs <- mget(ls(envir = envir), envir = envir)
      Onames <- names(Objs)
      tests <- character()
      if (length(Objs) > 0) {
        for (i in 1:length(Objs)) {
          if (is.svTest(Objs[[i]])) {
            tests <- c(tests, Onames[i])
          } else if (is.test(Objs[[i]])) {
            tests <- c(tests, paste("test(", Onames[i], ")", sep = ""))
          }
        }
      }
    }
    items <- c(items, sort(tests))
  }

  # 3) Additional directories (check that they are valid and existing dirs)
  if (!is.null(dirs)) {
    # Check if each entry exists as a directory, exclude it if not
    # Prepend "dir:" to tag them as additional directories
    Dirs <- character()
    for (Dir in dirs)
      if (file.exists(Dir) && file.info(Dir)$isdir)
        Dirs <- c(Dirs, paste("dir", Dir, sep = ":"))
    items <- c(items, sort(Dirs))
  }

  # Filter the resulting list with 'excludeList'
  if (!is.null(excludeList)) {
    for (pattern in excludeList)
      items <- items[regexpr(pattern, items) == -1]
  }

  # Do we load the package?
  if (loadPackages) {
    # Get a list of packages we need for the suite
    Pkgs <- items[regexpr("^package:", items)]
    PkgsSrch <- unique(sub(" +\\(.+$", "", Pkgs))
    l <- length(PkgsSrch)
    if (l > 0) {
      PkgsName <- sub("^package:", "", PkgsSrch)
      Search <- search()
      for (i in 1:l) {
        if (!PkgsSrch[i] %in% Search) {
          res <- try(library(PkgsName[i], character.only = TRUE),
            silent = TRUE)
          if (inherits(res, "try-error"))
            warning("Cannot load package '", PkgsName[i], "'")
        }
      }
    }
  }

  # Make it a 'svSuite' object subclassing 'character'
  class(items) <- c("svSuite", "character")
  items
}

#' @export
#' @rdname svSuite
makeUnit.svSuite <- function(x, name = make.names(deparse(substitute(x))),
dir = tempdir(), objfile = "", codeSetUp = NULL, codeTearDown = NULL,
pos = .GlobalEnv, ...) {
  # Take an 'svSuite' object and make a unit from its function tests
  # that are not written yet in a test unit in a file
  # They are saved in a file named runit<name>.R in 'dir'
  if (!is.svSuite(x))
    stop("'x' must be a 'svSuite' object")
  name <- as.character(name)[1]
  # Under Windows, we transform \\ into /
  dir <- gsub("\\\\", "/", as.character(dir)[1])
  # Collect all items that are not 'package:...' or 'dir:...'
  isObj <- regexpr("^[package:|dir:]", x) == -1
  Objs <- sub("^test[(](.+)[)]$", "\\1", x[isObj])
  if (length(Objs) == 0) {# No objects, return NULL
    return(NULL)
  } else {# Make a sourceable test unit file with tests collected in Objs
    Unit <- .prepareUnit(name, dir)
    .writeSetUp(unit = Unit, file = objfile, code = codeSetUp)
    .writeTearDown(unit = Unit, code = codeTearDown)
    for (objname in Objs)
      .writeTest(unit = Unit, objname = objname, pos = pos)
  }
  Unit
}

#' @export
#' @rdname svSuite
runTest.svSuite <- function(x, name = make.names(deparse(substitute(x))),
unitname = NULL, ...) {
  # Compile and run the test for this 'svSuite' object
  if (!is.svSuite(x))
    stop("'x' must be a 'svSuite' object")
  name <- as.character(name[1])

  # Decode tests contained in x
  tests <- as.character(x)
  dirs <- character()
  # Package suites...
  isPkg <- regexpr("^package:", tests) > -1
  if (any(isPkg)) {
    Pkgs <- tests[isPkg]
    Subdirs <- sub("^.+[(](.+)[)] *$", "\\1", Pkgs)
    Subdirs[Subdirs == Pkgs] <- ""
    Pkgs <- sub("^package:([^ ]+).*$", "\\1", Pkgs)
    for (i in 1:length(Pkgs)) {
      if (Subdirs[i] == "") {
      dir <- system.file(package = Pkgs[i], "unitTests")
    } else {
      dir <- system.file(package = Pkgs[i], "unitTests", Subdirs[i])
    }
      if (dir != "")
        dirs <- c(dirs, dir)
    }
  }

  # Add directories, and possibly make a temporary unit for test objects
  if (any(!isPkg)) {
    tests <- tests[!isPkg]
    # Directories
    isDir <- regexpr("^dir:", tests) > -1
    if (any(isDir))
      dirs <- c(sub("^dir:", "", tests[isDir]), dirs)
    # Objects
    if (any(!isDir)) {
      # Make a temporary unit for the tests of these objects
      if (!is.null(Unit <- makeUnit(x, name = name))) {
        # Add this path to dirs
        dirs <- c(dirname(Unit), dirs)
      }
    }
  }

  # Now, list all files in these dirs with name being runit*.R
  files <- character()
  for (dir in dirs)
    files <- c(files, list.files(dir, pattern = "^runit.+\\.[rR]$",
      full.names = TRUE))
  if (length(files) == 0) return(NULL)  # Nothing to run!
  # Under Windows, transform all \\ into / in the file names
  files <- gsub("\\\\", "/", files)
  # Added by Thomas Wurtzler to control which unit test to run
  if (!is.null(unitname)) {
    unitname <- deparse(substitute(unitname))
    testNames <- gsub("^.*runit(.+)\\.[rR]$", "\\1", files)
    keep <- which(testNames == unitname)
    files <- files[keep]
    if (length(files) == 0) {
      warning("Test unit ", unitname, " not found")
      return(NULL)
    }
  }
  # Run this test suite now, that is, source each file in .TestSuiteEnv
  # and run each testxxx function in it, using .setUp and .tearDown too
  # Record the list of tests
  .lastSuite <- list()
  for (file in files)
    .lastSuite[[basename(file)]] <- list(file = file)
  .Log <- Log()
  .Log$.lastSuite <- .lastSuite

  # Source each runit*.R file in turn
  for (unit in names(.lastSuite)) {
    # Create a new environment for this suite.
    .ThisTestSuiteEnv <- new.env(parent = .GlobalEnv)
    # Store it in SciViews:TempEnv so that we can inspect it in case of
    # stop on error. But please do not remove the local alias.  #1327
    .assignTemp(".TestSuiteEnv", .ThisTestSuiteEnv)
    # Source the corresponding file
    Unit <- .lastSuite[[unit]]$file
    sys.source(Unit, envir = .ThisTestSuiteEnv)
    # Make sure there are .setUp() and .tearDown() functions
    if (!exists(".setUp", envir = .ThisTestSuiteEnv, mode = "function",
      inherits = FALSE))
      .ThisTestSuiteEnv$.setUp <- function() {}
    if (!exists(".tearDown", envir = .ThisTestSuiteEnv, mode = "function",
      inherits = FALSE))
      .ThisTestSuiteEnv$.tearDown <- function() {}
    # List all test files in the unit
    tests <- ls(.ThisTestSuiteEnv, pattern = "^test.+$")
    # Keep only 'test*' objects that are function
    keep <- unlist(lapply(tests, function(n) exists(n,
      envir = .ThisTestSuiteEnv, mode = "function", inherits = FALSE)))
    tests <- tests[keep]
    .Log$.lastSuite[[unit]]$tests <- tests
    # Run each test in turn
    for (test in tests)
      .runTest(envir = .ThisTestSuiteEnv, test = test, unit = Unit)
  }
  invisible(files)
}
