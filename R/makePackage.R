
makePackage <- function(packageName, assignList = list(), aggregateList = list(), symbols = list(), clientPrefix = 'ds.', serverSuffix = 'DS',
                        authors = 'person("Iulian", "Dragan", email = "iulian.dragan@sib.swiss", role = c("aut", "cre"))',
                        license = NULL, destPath = '.'){
  # restart every time:
  unlink(paste0(tempdir(), '/', packageName), recursive = TRUE)
  myDir <- tempdir()
  assignFuncList <- lapply(names(assignList), function(packName){
     sapply(assignList[[packName]], function(funName){
      syms <- c(symbols[[funName]], unlist(symbols[names(symbols)=='']))
      ret <- makeOneFunction(packName, funName, 'assign', 'DS', syms)
      ret$client <- paste0(clientPrefix, funName,' <- ', ret$client)
      ret$server <- paste0( funName, serverSuffix, ' <- ', ret$server)
      return(ret)
     }, simplify = FALSE)
   })
  aggregateFuncList <- lapply(names(aggregateList), function(packName){
    sapply(aggregateList[[packName]], function(funName){
      syms <- c(symbols[[funName]], unlist(symbols[names(symbols)=='']))
      ret <-makeOneFunction(packName, funName, 'aggregate', 'DS', syms)
      ret$client <- paste0(clientPrefix, funName,' <- ', ret$client)
      ret$server <- paste0( funName, serverSuffix, ' <- ', ret$server)
      return(ret)
    })
  }, simplify = FALSE)
  c(unlist(assignFuncList, recursive = FALSE), unlist(aggregateFuncList, recursive = FALSE),
    sapply(c('.encode.arg', '.decode.arg' ), function(fname){
      fsource <- capture.output(print(get(fname, envir = as.environment('package:dsWrapR'))))
      fsource[1] <- paste0(fname, ' <- ',fsource[1])
    # without the lines starting with "<" (meta package rubbish)
     # cat(fsource[grep('^<', fsource, invert = TRUE)], file = paste0(myDir,'/', packageName,'/R/',fname,'.R'), sep ="\n")
      paste(fsource[grep('^<', fsource, invert = TRUE)], collapse = "\n")
    }, simplify = FALSE))
}
