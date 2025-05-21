test_that("I can create and load dsMissForest/dsMissForestClient", {
  dPath = paste0(tempdir(TRUE), '/test_dsWrapper')
  unlink(dPath, recursive = TRUE)
  dir.create(dPath)
  makePackage('dsMissForest', assignList = list(missForest = c('missForest', 'prodNA')),
              aggregateList = list(missForest = c('mixError', 'nrmse')),
              symbols = list('ximp', 'xmiss', 'xtrue', 'x'),
              authors = 'person("Iulian", "Dragan", email = "iulian.dragan@sib.swiss", role = c("aut", "cre"))',
              license = 'GPLv3', destPath = dPath)
  devtools::load_all(paste0(dPath, '/dsMissForestClient'))
  devtools::load_all(paste0(dPath, '/dsMissForest'))
  x <-sessionInfo(package = c('dsMissForest', 'dsMissForestClient'))
  expect_equal(names(x$otherPkgs), c('dsMissForest', 'dsMissForestClient'))

})
