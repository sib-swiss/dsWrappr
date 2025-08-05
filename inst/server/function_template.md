function(...){
  argList <- list(...)  
  myEnv <- parent.frame()
  argNames <- names(argList)
  if(is.null(argNames)){
    argNames <- rep('', length(argList))
  }
  
  argList <- Map(function(name, value){
    retval <- .decode.arg(value)
    @beginSymbolClauseif(name %in% c(@symbolList)){
      retval <- as.symbol(retval)
    }@endSymbolClause
    return(retval)
  }, argNames, argList)  
  
  
  val <- do.call(@packageName::@functionName, argList, envir = myEnv)
 
  #stop('Please make sure you review the return object and remove any potential disclosures. Once done, please remove this line')
  return(val)
 }

