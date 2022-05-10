# svUnit

<!-- badges: start -->

[![R-CMD-check](https://github.com/SciViews/svUnit/workflows/R-CMD-check/badge.svg)](https://github.com/SciViews/svUnit/actions) [![Win Build Status](https://ci.appveyor.com/api/projects/status/github/SciViews/svUnit?branch=master&svg=true)](https://ci.appveyor.com/project/phgrosjean/svUnit) [![Coverage Status](https://img.shields.io/codecov/c/github/SciViews/svUnit/master.svg)](https://codecov.io/github/SciViews/svUnit?branch=master) [![CRAN Status](https://www.r-pkg.org/badges/version/svUnit)](https://cran.r-project.org/package=svUnit) [![License](https://img.shields.io/badge/license-GPL-blue.svg)](https://www.gnu.org/licenses/gpl-2.0.html) [![Life cycle stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://www.tidyverse.org/lifecycle/#stable)

<!-- badges: end -->

{svUnit} is a testing framework inspired by {RUnit}, itself inspired by xUnit/jUnit. It is similar and compatible with {RUnit}, but implemented differently internally. Test suite written for {RUnit} or {svUInit} should be intercompatible. Look at the documentation to discover what {svUnit} offers for testing your R packages.

## Installation

The latest stable version of {svUnit} can simply be installed from [CRAN](http://cran.r-project.org):

``` r
install.packages("svUnit")
```

You can also install the latest development version. Make sure you have the {remotes} R package installed:

``` r
install.packages("remotes")
```

Use `install_github()` to install the {svUnit} package from Github (source from **master** branch will be recompiled on your machine):

``` r
remotes::install_github("SciViews/svUnit")
```

R should install all required dependencies automatically, and then it should compile and install {svUnit}.

Latest devel version of {svUnit} (source + Windows binaries for the latest stable version of R at the time of compilation) is also available from [appveyor](https://ci.appveyor.com/project/phgrosjean/svUnit/build/artifacts).

## Further explore {svUnit}

You can get further help about this package this way: Make the {svUnit} package available in your R session:

``` r
library("svUnit")
```

Get help about this package:

``` r
library(help = "svUnit")
help("svUnit-package")
vignette("svUnit") # None is installed with install_github()
```

For further instructions, please, refer to these help pages at <https://www.sciviews.org/svUnit/>.

## Code of Conduct

Please note that the {svUnit} project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.

## Note to developers

This package used to be developed on R-Forge in the past. However, the latest [R-Forge version](https://r-forge.r-project.org/projects/sciviews/) was moved to this GitHub repository on 2016-03-17 (SVN version 569). **Please, do not use R-Forge anymore for SciViews development, use this GitHub repository instead.**
