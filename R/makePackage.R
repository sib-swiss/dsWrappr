
makePackage <- function(packageName, assignList = list(), aggregateList = list(), symbols = list(), clientPrefix = 'ds.', serverSuffix = 'DS',
                        authors = 'person("Iulian", "Dragan", email = "iulian.dragan@sib.swiss", role = c("aut", "cre"))',
                        license = NULL, destPath = '.'){
  # restart every time:
  unlink(paste0(tempdir(), '/', packageName), recursive = TRUE)
  myDir <- tempdir()
  assignFuncList <- sapply(names(assignList), function(packName){
     sapply(assignList[[packName]], function(funName){
       makeOneFunction(packName, funName, 'assign', 'DS', symbols[[funName]])
     })
   })
  aggregateFuncList <- sapply(names(aggregateList), function(packName){
    sapply(aggregateList[[packName]], function(funName){
      makeOneFunction(packName, funName, 'assign', 'DS', symbols[[funName]])
    })
  })
  c(assignFuncList, aggregateFuncList)

}
