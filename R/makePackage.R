
makePackage <- function(packageName, assignList = list(), aggregateList = list(), symbols = list(), clientPrefix = 'ds.', serverSuffix = 'DS',
                        authors = NULL, license = NULL, destPath = NULL){
  if (is.null(destPath)){
    destPath <- getwd()
  }
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
      syms <- symbols[[funName]]
      if(length(syms) == 0){
        syms <- unique(c(unlist(symbols[names(symbols)=='']), unlist(symbols[is.null(names(symbols))])))
      }
      #print(syms)
      ret <- makeOneFunction(packName, funName, 'assign', clientPrefix, serverSuffix , syms)
      clientFun <- paste0(clientPrefix, funName)
      serverFun <- paste0(funName, serverSuffix)
      clientFile <- paste0(clientDir,'/',clientFun, '.R')
      serverFile <- paste0(serverDir,'/',serverFun, '.R')
#      cat(paste0(clientFun,' <- ', ret$client), file = clientFile)
#      cat(paste0( serverFun, ' <- ', ret$server), file = serverFile)
      cat(ret$client, file = clientFile)
      cat(ret$server, file = serverFile)

      return(serverFun)
     })
   })
  aggregateFuncList <- lapply(names(aggregateList), function(packName){
    sapply(aggregateList[[packName]], function(funName){
      syms <- symbols[[funName]]
      if(length(syms) == 0){
        syms <- unique(c(unlist(symbols[names(symbols)=='']), unlist(symbols[is.null(names(symbols))])))
      }
      ret <-makeOneFunction(packName, funName, 'aggregate', clientPrefix, serverSuffix, syms)
      clientFun <- paste0(clientPrefix, funName)
      serverFun <- paste0(funName, serverSuffix)
      clientFile <- paste0(clientDir,'/',clientFun, '.R')
      serverFile <- paste0(serverDir,'/',serverFun, '.R')
     # cat(paste0(clientFun,' <- ', ret$client), file = clientFile)
    #  cat(paste0( serverFun, ' <- ', ret$server), file = serverFile)
      cat(ret$client, file = clientFile)
      cat(ret$server, file = serverFile)

      return(serverFun)
    })
  })

  Map(function(fname,dest){
      fsource <- capture.output(print(get(fname, envir = as.environment('package:dsWrappr'))))
      fsource[1] <- paste0(fname, ' <- ',fsource[1])
      # without the lines starting with "<" (meta package rubbish)
      cat(fsource[grep('^<', fsource, invert = TRUE)], file = paste0(dest,'/little_helpers.R'), sep ="\n")
      #paste(fsource[grep('^<', fsource, invert = TRUE)], collapse = "\n")
    }, c('.encode.arg', '.decode.arg', '.deep.extract'), c(clientDir, serverDir, serverDir))

  # create the packages:

  package.skeleton(name = packageName, path = destPath, code_files = list.files(serverDir, full.names = TRUE), force = TRUE)
  package.skeleton(name = clientPackageName, path = destPath, code_files = list.files(clientDir, full.names = TRUE), force = TRUE)

  # DESCRIPTION
  servDesc <- readLines(system.file('server', 'DESCRIPTION', package='dsWrappr'))
  servDesc[1] <- paste0(servDesc[1],' ', packageName)
  servDesc[3] <- paste0(servDesc[3],' ', packageName)
  servDesc[5] <- paste0(servDesc[5],' ', Sys.Date())
  servDesc[6] <- paste0('Authors@R: ', authors)
  servDesc[7] <- paste0(servDesc[7], ' Datashield implementation of selected functions from ',
                        paste(unique(c(names(assignList), names(aggregateList))), collapse = ', '), '. Server package.')
  if(!is.null(license)){
    servDesc[8] <- paste0(servDesc[8],' ', license)
  }
  servDesc[9] <- paste0("AssignMethods:\n    ", paste(unlist(assignFuncList), collapse = ",\n   "))
  servDesc[10] <- paste0("AggregateMethods:\n    ", paste(unlist(aggregateFuncList), collapse = ",\n   "))

  clDesc <- readLines(system.file('client', 'DESCRIPTION', package='dsWrappr'))
  clDesc[1] <- paste0(clDesc[1],' ', clientPackageName)
  clDesc[3] <- paste0(clDesc[3],' ', clientPackageName)
  clDesc[5] <- paste0(clDesc[5],' ', Sys.Date())
  clDesc[6] <- paste0('Authors@R: ', authors)
  clDesc[7] <- paste0(clDesc[7],' Datashield implementation of selected functions from ',
                        paste(unique(c(names(assignList), names(aggregateList))), collapse = ', '), '. Client package.')
  if(!is.null(license)){
    clDesc[8] <- paste0(clDesc[8],' ', license)
  }

  cat(clDesc, file = paste0(destPath, '/', clientPackageName, '/DESCRIPTION'), sep ="\n")
  cat(servDesc, file = paste0(destPath, '/', packageName ,'/DESCRIPTION'), sep ="\n")
  dir.create(paste0(destPath, '/', packageName, '/inst'))
  #AssignMethods
 # cat(paste0("AssignMethods:\n    ", paste(unlist(assignFuncList), collapse = ",\n", sep = "    ")),
  #          file = paste0(destPath, '/', packageName, '/inst/DATASHIELD'))
  #AggregateMethods
#  cat(paste0("\nAggregateMethods:\n    ", paste(unlist(aggregateFuncList), collapse = ",\n", sep = "    ")),
 #             file = paste0(destPath, '/', packageName, '/inst/DATASHIELD'), append = TRUE)

  #test:
  withr::with_dir(paste0(destPath, '/', clientPackageName),{
    usethis::use_testthat()
  })
  setupCode <- readLines(system.file('client', 'setup-init.R', package='dsWrappr'))
  setupCode[4] <- sub('<server_package_path>', paste0(destPath, '/',packageName), setupCode[4])
  setupCode[5] <- sub('<server_package>', packageName, setupCode[5])
  setupCode[6] <- sub('<server_package>', packageName, setupCode[5])
  cat(setupCode, file = paste0(destPath, '/', clientPackageName, '/tests/testthat/setup-init.R'), sep ="\n")
  return(destPath)

}
