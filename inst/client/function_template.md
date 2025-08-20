#' @title  Remote "@origFuncName"
#' @description Executes "@origFuncName" from the library "@packageName" on the remote nodes
#' @param @firstArg, first argument to be sent to @origFuncName on the remote nodes. Please check the original function documentation for details.@beginFirstArg @firstArg should be a character, enclosed in quotes.@endFirstArg
#' @param ...,  remainder of the @origFuncName arguments.
@beginAssignVar
#' @param @assignVar, a character, the name of the new object to be created in the remote sessions.
@endAssignVar
#' @param async same as in datashield.@op
#' @param datasources same as in datashield.@op

@clientFunction <- function(@firstArg, @assignVar = 'newObj', ..., async = TRUE, datasources = NULL){
  if(is.null(datasources)){
    datasources <- datashield.connections_find()
  } 
  argList <- list(@firstArg = @firstArg, ...)
  expr <- c(as.symbol('@serverFunction'), 
              sapply(argList, .encode.arg, TRUE, simplify = FALSE))
  ret <- datashield.@op(datasources, @assignVar, as.call(expr), async)            
  return(@retVal)          
  }
