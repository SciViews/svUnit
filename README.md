# svUnit

[![Linux & OSX Build Status](https://travis-ci.org/SciViews/svUnit.svg )](https://travis-ci.org/SciViews/svUnit)
[![Win Build Status](https://ci.appveyor.com/api/projects/status/github/SciViews/svUnit?branch=master&svg=true)](http://ci.appveyor.com/project/phgrosjean/svUnit)
[![Coverage Status](https://img.shields.io/codecov/c/github/SciViews/svUnit/master.svg)
](https://codecov.io/github/SciViews/svUnit?branch=master)
[![CRAN Status](http://www.r-pkg.org/badges/version/svUnit)](http://cran.r-project.org/package=svUnit)
[![License](https://img.shields.io/badge/license-GPL-blue.svg)](http://www.gnu.org/licenses/gpl-2.0.html)

SciViews - unit, integration and system testing.

_Build badges are as follows (R versions at the time of the build)._
- _Status for devel R version for both Linux and Mac OS X at left._
- _Status for the latest stable version of R under Windows at right._ 


## Installation

### Latest stable version

The latest stable version of **svUnit** can simply be installed from [CRAN](http://cran.r-project.org):

```r
install.packages("svUnit")
```


### Development version

Make sure you have the **devtools** R package installed:

```r
install.packages("devtools")
```

Use `install_github()` to install the **svUnit** package from Github (source from **master** branch will be recompiled on your machine):

```r
devtools::install_github("SciViews/svUnit")
```

R should install all required dependencies automatically, and then it should compile and install **svUnit**.

Latest devel version of **svUnit** (source + Windows binaires for the latest stable version of R at the time of compilation) is also available from [appveyor](https://ci.appveyor.com/project/phgrosjean/svUnit/build/artifacts).


## Usage

Make the **svUnit** package available in your R session:

```r
library("svUnit")
```

Get help about this package:

```r
library(help = "svUnit")
help("svUnit-package")
```

For further instructions, please, refer to these help pages.


## Note to developers

This package used to be developed on R-Forge in the past. However, the latest [R-Forge version](https://r-forge.r-project.org/projects/sciviews/) was moved to this Github repository on 2016-03-17 (SVN version 569). **Please, do not use R-Forge anymore for SciViews development, use this Github repository instead.**
