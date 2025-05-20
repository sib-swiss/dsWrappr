test_that("I can create the package dsMissForest", {
  makePackage('dsMissForest', assignList = list(missForest = c('missForest', 'prodNA')),
              aggregateList = list(missForest = c('mixError', 'nrmse')),
              symbols = list('ximp', 'xmiss', 'xtrue', 'x'),
              authors = 'person("Iulian", "Dragan", email = "iulian.dragan@sib.swiss", role = c("aut", "cre"))',
              license = 'GPLv3', destPath = '/mnt/shareddisk/datashield')
    #expect_equal(x$server1$Sepal.Length, c('low', 'high'))
})
