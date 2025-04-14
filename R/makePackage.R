makePackage <- function(packageName, sourceList = list(), authors = 'person("Iulian", "Dragan", email = "iulian.dragan@sib.swiss", role = c("aut", "cre"))', license = NULL, dest_path = '.'){
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

 sapply(names(srclist), function (packName){
   sapply(srclist[[packName]], function(funcName){



   }
 })
}
