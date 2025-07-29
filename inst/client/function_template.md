function(@assignVar, ..., async = TRUE, datasources = NULL){
  if(is.null(datasources)){
    datasources <- datashield.connections_find()
  } 
  argList <- list(...)
  expr <- c(as.symbol('@serverFunction'), 
              sapply(argList, .encode.arg, TRUE, simplify = FALSE))
  ret <- datashield.@op(datasources, @assignVar, as.call(expr), async)            
  return(@retVal)          
  }
