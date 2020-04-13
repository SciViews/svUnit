# Note that the message in case of error is not explicit enough.Moreover,
# nothing is printed in case of success, while we would like a succinct report
# TODO: check if warnings are not converted into errors during R CMD check tests
library(svUnit)
clearLog()
res <- capture.output(runTest(svSuite("package:svUnit"), "svUnit"))
errorLog()
