
makePackage <- function(packageName, sourceList = list(), symbols = list(), clientPrefix = 'ds.', serverSuffix = 'DS',
                        authors = 'person("Iulian", "Dragan", email = "iulian.dragan@sib.swiss", role = c("aut", "cre"))',
                        license = NULL, destPath = '.'){
  # restart every time:
  unlink(paste0(tempdir(), '/', packageName), recursive = TRUE)
  myDir <- tempdir()
  funcList <- sapply(names(sourceList), function(packName){
   sapply(c('assign', 'aggregate'), function(funType){
     sapply(sourceList[[packName]][[funType]], function(funName){
       makeOneFunction(packageName, funName, funType, 'DS', symbols[[funName]])
     })
   })
 })


}
