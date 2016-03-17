\name{guiTestReport}
\alias{guiTestReport}
\alias{guiTestFeedback}
\alias{guiSuiteList}
\alias{guiSuiteAutoList}

\title{ Report or give feedback to the GUI client about running test units }
\description{
  These functions are usually not called from the command line. They return
  data to compatible GUI clients, like Komodo Edit with the SciViews-K extension.
}

\usage{
guiTestReport(object, sep = "\t", path = NULL, \dots)
guiTestFeedback(object, path = NULL, \dots)
guiSuiteList(sep = "\t", path = NULL, compare = TRUE)
guiSuiteAutoList(\dots)
}

\arguments{
  \item{object}{ a svUnitData object. }
  \item{\dots}{ not used currently. }
  \item{sep}{ field separator to use in the results. }
  \item{path}{ path where to write a 'Suites.txt' file with the list of currently
    available test suites (to be used by the GUI client). If \code{NULL}, no
    file is written (by default). }
  \item{compare}{ do we compare the list of available test suite and return
    something to the GUI client only if there are changes in the list? This is
    used (when TRUE) to avoid unnecessary multiple processings of the same list
    by the GUI client. }
}

\value{
  \code{guiSuiteList()} returns the list of available test suites invisibly.
  \code{guiSuiteAutoList()} is used to establish a callback to automatically
  list the available test suites in the GUI. It is not intended to be called
  directly by the user. The other functions just return \code{TRUE} invisibly.
  They are used for their side effect of sending data to compatible GUI clients.
}

\author{ Philippe Grosjean <phgrosjean@sciviews.org> }

\seealso{ \code{\link{svTest}}, \code{\link{svSuite}}, \code{\link{koUnit_version}} }

\keyword{ utilities }

\concept{ unit testing }
