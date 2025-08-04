test_that("I can create and load dsMissForest/dsMissForestClient", {
  #dPath <-  paste0(tempdir(TRUE), '/test_dsWrapper')
  unlink(dPath, recursive = TRUE)
  dir.create(dPath)
  makePackage('dsMissForest', assignList = list(missForest = c('missForest', 'prodNA')),
              aggregateList = list(missForest = c('mixError'), utils = 'data'),
              symbols = list( missForest = 'xmis', prodNA = 'x', mixError = c('ximp', 'xmis', 'xtrue')),
              authors = 'person("Iulian", "Dragan", email = "iulian.dragan@sib.swiss", role = c("aut", "cre"))',
              license = 'GPLv3', destPath = dPath)
  devtools::load_all(paste0(dPath, '/dsMissForestClient'))
  devtools::load_all(paste0(dPath, '/dsMissForest'))
  x <-sessionInfo(package = c('dsMissForest', 'dsMissForestClient'))
  expect_equal(names(x$otherPkgs), c('dsMissForest', 'dsMissForestClient'))

})

test_that("I can build dsMissForest/dsMissForestClient", {

  s <- devtools::build(paste0(dPath, '/dsMissForest'))
  cl <- devtools::build(paste0(dPath, '/dsMissForestClient'))
  expect_equal(c(s,cl), c(paste0(dPath, '/dsMissForest_0.1.tar.gz'), paste0(dPath, '/dsMissForestClient_0.1.tar.gz')))

})

test_that("I can run functions from dsMissForest in a dsLite environment", {
  library(magrittr)
  install.packages(paste0(dPath, '/dsMissForest_0.1.tar.gz'))

  dslite.server1 <<- newDSLiteServer(config = defaultDSConfiguration(include=c('dsBase', 'dsMissForest')))
  builder <- newDSLoginBuilder()
  builder$append(server="server1", url='dslite.server1',driver = "DSLiteDriver")

  logindata <- builder$build()
  opals <<- datashield.login(logins = logindata)
  session1 <- dslite.server1$getSession(dslite.server1$getSessionIds())


  data('iris', envir = session1) %>% ds.prodNA(newObj = 'iris_na')
  %>% ds.missForest('iris_new') %>% ds.mixError('iris_na', 'iris')

  ds.prodNA('iris.na', x ='iris' )
  expect_false(all(complete.cases(session1$iris.na)))
  ds.missForest('iris_new', TRUE, NULL, xmis = 'session1$iris.na' )
  expect_true(all(complete.cases(session1$iris_new)))

})

