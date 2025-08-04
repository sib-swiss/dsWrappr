function(...){
  argList <- list(...)  
  myEnv <- parent.frame()
  namedArgs <- argList[names(argList)!='']
  unnamedArgs <- argList[names(argList)=='']
  namedArgs <- sapply(names(namedArgs), function(x){
    ret <- .decode.arg(namedArgs[[x]])
@symbolClause
    return(ret)
  }, simplify = FALSE)
  unnamedArgs <- lapply(unnamedArgs, function(x){
  .decode.arg(x)
  })
  argList  
  val <- do.call(@packageName::@functionName, argList, envir = myEnv)
 
  #stop('Please make sure you review the return object and remove any potential disclosures. Once done, please remove this line')
  return(val)
 }
