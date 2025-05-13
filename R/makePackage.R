
makePackage <- function(packageName, assignList = list(), aggregateList = list(), symbols = list(), clientPrefix = 'ds.', serverSuffix = 'DS',
                        authors = 'person("Iulian", "Dragan", email = "iulian.dragan@sib.swiss", role = c("aut", "cre"))',
                        license = NULL, destPath = getwd()){
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
      syms <- unique(c(symbols[[funName]], unlist(symbols[names(symbols)==''])))
      ret <- makeOneFunction(packName, funName, 'assign', serverSuffix , syms)
      clientFun <- paste0(clientPrefix, funName)
      serverFun <- paste0(funName, serverSuffix)
      clientFile <- paste0(clientDir,'/',clientFun, '.R')
      serverFile <- paste0(serverDir,'/',serverFun, '.R')
      cat(paste0(clientFun,' <- ', ret$client), file = clientFile)
      cat(paste0( serverFun, ' <- ', ret$server), file = serverFile)
      return(serverFun)
     })
   })
  aggregateFuncList <- lapply(names(aggregateList), function(packName){
    sapply(aggregateList[[packName]], function(funName){
      syms <- unique(c(symbols[[funName]], unlist(symbols[names(symbols)==''])))
      ret <-makeOneFunction(packName, funName, 'aggregate', 'DS', syms)
      clientFun <- paste0(clientPrefix, funName)
      serverFun <- paste0(funName, serverSuffix)
      clientFile <- paste0(clientDir,'/',clientFun, '.R')
      serverFile <- paste0(serverDir,'/',serverFun, '.R')
      cat(paste0(clientFun,' <- ', ret$client), file = clientFile)
      cat(paste0( serverFun, ' <- ', ret$server), file = serverFile)
      return(serverFun)
    })
  })

  Map(function(fname,dest){
      fsource <- capture.output(print(get(fname, envir = as.environment('package:dsWrapR'))))
      fsource[1] <- paste0(fname, ' <- ',fsource[1])
      # without the lines starting with "<" (meta package rubbish)
      cat(fsource[grep('^<', fsource, invert = TRUE)], file = paste0(dest,'/little_helpers.R'), sep ="\n")
      #paste(fsource[grep('^<', fsource, invert = TRUE)], collapse = "\n")
    }, c('.encode.arg', '.decode.arg'), c(clientDir, serverDir))

  # create the packages:

  package.skeleton(name = packageName, path = destPath, code_files = list.files(serverDir, full.names = TRUE))
  package.skeleton(name = clientPackageName, path = destPath, code_files = list.files(clientDir, full.names = TRUE))

  # DESCRIPTION
  servDesc <- readLines(system.file('server', 'DESCRIPTION', package='dsWrapR'))
  servDesc[1] <- paste0(servDesc[1],' ', packageName)
  servDesc[5] <- paste0(servDesc[5],' ', Sys.Date())
  servDesc[6] <- paste0('Authors@R: ', authors)
  #AggregateMethods
 # servDesc[10] <-paste0(servDesc[10], paste(unlist(aggregateFuncList), collapse = ', '))
  #AssignMethods
#  servDesc[11] <-paste0(servDesc[11], paste(unlist(assignFuncList), collapse = ', '))
  if(!is.null(license)){
    servDesc[8] <- paste0(servDesc[8],' ', license)
  }
  clDesc <- readLines(system.file('client', 'DESCRIPTION', package='dsWrapR'))
  clDesc[1] <- paste0(clDesc[1],' ', clientPackageName)
  clDesc[5] <- paste0(clDesc[5],' ', Sys.Date())
  clDesc[6] <- paste0('Authors@R: ', authors)
  if(!is.null(license)){
    clDesc[8] <- paste0(clDesc[8],' ', license)
  }

  cat(clDesc, file = paste0(destPath, '/', clientPackageName, '/DESCRIPTION'), sep ="\n")
  cat(servDesc, file = paste0(destPath, '/', packageName ,'/DESCRIPTION'), sep ="\n")
  dir.create(paste0(destPath, '/', packageName, '/inst'))
  #AssignMethods
  cat(paste0("AssignMethods:\n    ", paste(unlist(assignFuncList), collapse = ",\n", sep = "    ")),
            file = paste0(destPath, '/', packageName, '/inst/DATASHIELD'))
  #AggregateMethods
  cat(paste0("\nAggregateMethods:\n    ", paste(unlist(aggregateFuncList), collapse = ",\n", sep = "    ")),
              file = paste0(destPath, '/', packageName, '/inst/DATASHIELD'), append = TRUE)
  return(destPath)

}
