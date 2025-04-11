makeOneClientFunction <- function(funcName, funcType = c('aggregate','assign'), assignVar = NULL, suffix = 'DS'){
  if (length(funcType) > 1){
    stop('funcType must be one of "aggregate" and "assign"')
  }
  if(funcType == 'assign' ){
    if(is.null(assignVar)){
      assignVar <- 'newObj'
    }
    func <- paste0("function(", assignVar, ", async, datasources, ...)\n ")
  } else if(funcType == 'aggregate'){
    func <- "function(async, datasources, ...)\n "
  } else {
    stop('funcType must be one of "aggregate" and "assign"')
  }


  func <- paste0(func, "if(is.null(datasources)){\n  datasources <- datashield.connections_find()\n }\n arglist <- .encode.arg(list(...), serialize.it = TRUE)\n ")
  func <- paste0(func, "myCall <- paste0('",funcName, suffix, "(\"',arglist,'\")')\n ")
  if(funcType == 'assign' ){
    func <- paste0(func, "datashield.assign(datasources, ", assignVar, ", as.symbol(myCall), async)\n }")
  } else { # aggregate
    func <- paste0(func, "datashield.aggregate(datasources, as.symbol(myCall), async)\n }")
  }

  return(func)
}

