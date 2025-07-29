function(...){
  argList <- list(...)  
  myEnv <- parent.frame()
  argList <- sapply(names(argList), function(x){
    ret <- .decode.arg(argList[[x]])
    if(x %in% c(@symbolList)){   
      ret <- as.symbol(ret)  
    }
  }, simplify = FALSE)
    
  val <- do.call(@packageName::@functionName, argList, envir = myEnv)
 
  stop('Please make sure you review the return object and remove any potential disclosures. Once done, please remove this line')
  return(val)
 }
