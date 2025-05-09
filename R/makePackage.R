
makePackage <- function(packageName, assignList = list(), aggregateList = list(), symbols = list(), clientPrefix = 'ds.', serverSuffix = 'DS',
                        authors = 'person("Iulian", "Dragan", email = "iulian.dragan@sib.swiss", role = c("aut", "cre"))',
                        license = NULL, destPath = '.'){
  # restart every time:
  clientPackageName <- paste0(packageName, 'Client')
  unlink(paste0(tempdir(), '/', packageName), recursive = TRUE)
  unlink(paste0(tempdir(), '/', clientPackageName), recursive = TRUE)
  serverDir <- paste0(tempdir(), '/', packageName)
  clientDir <- paste0(tempdir(), '/', clientPackageName)
  dir.create(serverDir)
  dir.create(clientDir)
  assignFuncList <- lapply(names(assignList), function(packName){
     sapply(assignList[[packName]], function(funName){
      syms <- c(symbols[[funName]], unlist(symbols[names(symbols)=='']))
      ret <- makeOneFunction(packName, funName, 'assign', 'DS', syms)
      clientFun <- paste0(clientPrefix, funName)
      serverFun <- paste0(funName, serverSuffix)
      clientFile <- paste0(clientDir,'/',clientFun, '.R')
      serverFile <- paste0(serverDir,'/',serverFun, '.R')
      cat(paste0(clientFun,' <- ', ret$client), file = clientFile)
      cat(paste0( serverFun, ' <- ', ret$server), file = serverFile)
     })
   })
  aggregateFuncList <- lapply(names(aggregateList), function(packName){
    sapply(aggregateList[[packName]], function(funName){
      syms <- c(symbols[[funName]], unlist(symbols[names(symbols)=='']))
      ret <-makeOneFunction(packName, funName, 'aggregate', 'DS', syms)
      clientFun <- paste0(clientPrefix, funName)
      serverFun <- paste0(funName, serverSuffix)
      clientFile <- paste0(clientDir,'/',clientFun, '.R')
      serverFile <- paste0(serverDir,'/',serverFun, '.R')
      cat(paste0(clientFun,' <- ', ret$client), file = clientFile)
      cat(paste0( serverFun, ' <- ', ret$server), file = serverFile)
    })
  })

  Map(function(fname,dest){
      fsource <- capture.output(print(get(fname, envir = as.environment('package:dsWrapR'))))
      fsource[1] <- paste0(fname, ' <- ',fsource[1])
      # without the lines starting with "<" (meta package rubbish)
      cat(fsource[grep('^<', fsource, invert = TRUE)], file = paste0(dest,'/little_helpers.R'), sep ="\n")
      #paste(fsource[grep('^<', fsource, invert = TRUE)], collapse = "\n")
    }, c('.encode.arg', '.decode.arg'), c(clientDir, serverDir))

}
