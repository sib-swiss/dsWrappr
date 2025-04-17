
makePackage <- function(packageName, sourceList = list(),
                        authors = 'person("Iulian", "Dragan", email = "iulian.dragan@sib.swiss", role = c("aut", "cre"))',
                        license = NULL, destPath = '.'){
  # restart every time:
  unlink(paste0(tempdir(), '/', packageName), recursive = TRUE)
  myDir <- tempdir()
  sapply(names(sourceList), function(packName){
   sapply(c('assign', 'aggregate'), function(funType){
     sapply(sourceList[[packName]][[funType]], function(funName){
       clientFunc <- makeOneClientFunction(funName, funType, )

     })
   })
 })

 sapply(names(srclist), function (packName){
   sapply(srclist[[packName]], function(funcName){
   clientFunc <- makeOneClientFunction()



   })
 })

}
