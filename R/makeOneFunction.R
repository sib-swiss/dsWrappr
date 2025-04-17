makeOneFunction <- function(package, funcName, funcType = c('aggregate','assign'), serverSuffix = 'DS', symbols = NULL, assignVar = NULL ){
func <- list()
### client
  if (length(funcType) > 1){
    stop('funcType must be one of "aggregate" and "assign"')
  }
  if(funcType == 'assign' ){
    if(is.null(assignVar)){
      assignVar <- 'newObj'
    }
    func$client <- paste0("function(", assignVar, ", async, datasources, ...)\n ")
  } else if(funcType == 'aggregate'){
    func$client <- "function(async, datasources, ...)\n "
  } else {
    stop('funcType must be one of "aggregate" and "assign"')
  }


  func$client <- paste0(func$client, "if(is.null(datasources)){\n  datasources <- datashield.connections_find()\n }\n argList <- list(...)\n ") #arglist <- .encode.arg(list(...), serialize.it = TRUE)\n ")
  func$client <- paste0(func$client, "expr <- c(as.symbol('",funcName, serverSuffix, "'), sapply(names(argList), function(x){\n  ")
  printSyms <- paste(symbols, collapse = "', '")
  func$client <- paste0(func$client, "if(x %in% c('", printSyms, "')){\n   return(as.symbol(argList[[x]]))\n  } else {\n   return(.encode.arg(argList[[x]], serialize.it = TRUE))\n  }\n }, simplify = FALSE))\n ")
  # func <- paste0(func, "myCall <- paste0('",funcName, suffix, "(\"',arglist,'\")')\n ")
  if(funcType == 'assign' ){
    func$client <- paste0(func$client, "datashield.assign(datasources, ", assignVar, ", as.call(expr), async)\n}")
  } else { # aggregate
    func$client <- paste0(func$client, "datashield.aggregate(datasources, as.call(expr), async)\n}")
  }

  ### server
  func$server <- "function(...)\n argList <- list(...)\n "
  func$server <- paste0(func$server, "argList <- sapply(names(argList), function(x){\n  ")
  func$server <- paste0(func$server, "if(x %in% c('", printSyms, "')){\n   return(argList[[x]])\n  } else {\n   return(.decode.arg(argList[[x]]))\n  }\n }, simplify = FALSE)\n ")
  func$server <- paste0(func$server, 'out <- do.call(', package,'::', funcName, ', argList)\n ')
  func$server <- paste0(func$server, 'return(out)\n}')

  return(func)
}
