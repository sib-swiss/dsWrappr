makePackage <- function(packageName, sourceList = list(),
                        authors = 'person("Iulian", "Dragan", email = "iulian.dragan@sib.swiss", role = c("aut", "cre"))',
                        license = NULL, destPath = '.'){
 i <- 0
 srclist <- list()
 for(x in names(sourceList)){
  i <- i+1
   if(x == ''){
     srclist[[sourceList[[i]]]] <- getNamespaceExports(sourceList[[i]])
   } else {
    srclist[[x]] <- (sourceList[[i]])
   }
 }
 # restart every time:
 unlink(paste0(tempdir(), '/', packageName), recursive = TRUE)
 myDir <- tempdir()
 sapply(names(srclist), function (packName){
   sapply(srclist[[packName]], function(funcName){
   clientFunc <- makeOneClientFunction()


   }
 })
}
