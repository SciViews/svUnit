# svUnit To Do list

- Split the svUnit vignette inot a real getting started one, and a rationate + SciViews-k/Komodo vignettes.

- Drop the unmaintained SciViews-K/Komodo feature?

- Add a GUI support for Visual Studio Code (and Atom?)

- Refine code, snake case equivalent of functions names and get rid of utils `sessionInfo()` and `str()` dependencies + rename Log into what? tests?.

- Make it also compatible with 'testthat' (including in RStudio) and 'testit' (+ look at 'testthis' also).

- Be able to track the guilty line of code for each test and to output something
  like: `./inst/unitTest/runit.select.R:28:`... (would be most useful for Emacs)!

- We need accessors to `timing` and `max.kind`.

- `guiTestFeedback()` must be finished.

- Output results in html, latex, wiki, etc. format (`summary.svSuiteData()`).

- Queue tests to run and run them asynchronously using 'tcltk' and `after()` if
  this package is loaded and we are in `interactive()` mode.

- Translate this package.

- Increase test coverage for this package and provide a way to test failures and erros in tests... as success (because we want to test them too)!

- In `RUnit/share/R`, there are `checkCode.r` and `compareRUnitTestData.r`. The former provides functions to test R code in R files, the latter does a comparison of timings in two test set runs, using a tolerance value. Worth checking and integrating later on!

- Check RUnit compatibility with latest version.
