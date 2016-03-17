\name{koUnit}
\alias{koUnit_isAutoTest}
\alias{koUnit_setAutoTest}
\alias{koUnit_runTest}
\alias{koUnit_showRUnitPane}
\alias{koUnit_version}

\title{ Interact with the test unit GUI in Komodo/SciViews-K }
\description{
  These functions allow controlling the test unit module (R Unit tab at right)
  in Komodo with SciViews-K and SciViews-K Unit extensions
  (see http://www.sciviews.org/SciViews-K). R must be correctly connected to
  Komodo, meaning that the 'svGUI' package must be loaded with proper
  configuration of client/server socket connections between R and Komodo. See
  the manual about SciViews-K for more information. The functions defined here
  are the same as JavaScript functions defined in the 'sv.r.unit' namespace in
  Komodo/SciViews-K Unit. For instance, \code{koUnit_runTest()} is equivalent
  to \code{sv.r.unit.runTest();} in a Javascript macro in Komodo.
}

\usage{
koUnit_isAutoTest()
koUnit_setAutoTest(state)
koUnit_runTest()
koUnit_showRUnitPane(state)
koUnit_version()
}

\arguments{
  \item{state}{ \code{TRUE} or \code{FALSE}, or missing for
  \code{koUnit_showRUnitPane()}, in this case, the R Unit pane visibility is
  toggled. }
}

\value{
  \code{koUnit_isAutoTest()} returns \code{TRUE} if the test unit is in auto
  mode in Komodo (the selected tests are run automatically each time a .R file
  edited in Komodo is saved).

  \code{koUnit_version()} returns the version for which the SciViews-K Unit
  extension was designed for. This allow to check if this version is compatible
  with current 'svUnit' R package version, and to propose to update the Komodo
  extension if needed (this mechanism is not running currently, but it will be
  implemented in the future to avoid or limit incompatibilities between
  respective R and Komodo extensions).

  The other functions are invoked for their side effect and they return nothing.
  Note, however, that correct execution of this code in Komodo is verified, and
  the functions issue an error in R if they fail to execute correctly in Komodo.
}

\author{ Philippe Grosjean <phgrosjean@sciviews.org> }

\seealso{ \code{\link{guiTestReport}} }

\examples{
\dontrun{
## Make sure R is communicating with Komodo before use, see ?koCmd in svGUI
koUnit_version()

## Toggle visibility of the R Unit pane in Komodo twice
koUnit_showRUnitPane()
koUnit_showRUnitPane()

## Make sure that the R Unit pane is visible
koUnit_showRUnitPane(TRUE)

## Is the test unit running in auto mode?
koUnit_isAutoTest()

## Toggle auto test mode off
koUnit_setAutoTest(FALSE)

## Run the test units from within Komodo
koUnit_runTest()
}
}

\keyword{ utilities }

\concept{ unit testing }
