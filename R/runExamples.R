#' @export
#' @rdname svTest
makeTestListFromExamples <- function(packageName, manFilesDir,
skipFailing = FALSE) {
  manPageFiles <- list.files(manFilesDir, pattern = "\\.Rd$")
  manPages <- sapply(manPageFiles,
    function(filename) {
      lines <- readLines(paste(manFilesDir, filename, sep = "/"))
      lines <- lines[grep("^\\\\name[ ]*\\{(.*)\\}", lines)]
      sub("^\\\\name[ ]*\\{(.*)\\}", lines, replacement = "\\1")
    }
  )
  manPages <- manPages[manPages != paste(packageName, "package", sep = "-")]
  names(manPages) <- manPages

  lapply(manPages, function(x) {
    testCall <- call("example", x, packageName)
    if (skipFailing) {
      onFailure <- function(w) {
        DEACTIVATED(paste(w, collapse = "\n"))
        checkTrue(FALSE)
      }
    } else {
      onFailure <- function(w)
        checkIdentical(NULL, w)
    }
    result <- svTest(function() {
      tryCatch(
        withCallingHandlers({
          eval(testCall)
          checkTrue(TRUE)
        },
        warning = function(w)
          onFailure(w)),
        error = function(w)
          onFailure(w))
    })
    attr(result, 'unit') <- 'rcheck.examples'
    result
  })
}
