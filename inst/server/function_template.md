@serverFunction <- function(...){
  argList <- list(...)  
  myEnv <- parent.frame()
  argNames <- names(argList)
  if(is.null(argNames)){
    argNames <- rep('', length(argList))
  }
  
  argList <- Map(function(name, value){
    retval <- .decode.arg(value)
    @beginSymbolClause
    if(name %in% c(@symbolList)){
      retval <- .deep.extract(retval, startEnv =  myEnv)
    }
    @endSymbolClause
    return(retval)
  }, argNames, argList)  
  
  
  val <- do.call(@packageName::@functionName, argList, envir = myEnv)
  return(val)
 }

