makeOneServerFunction <- function(package, funcName, objectsInEnv = NULL, postProcessFunc = NULL){
  func <- "function(arglist)\n myparent <- parent.frame()\n arglist <- .decode.arg(arglist)\n "
  for (o in objectsInEnv){
    func <- paste0(func, "if(exists('", o, "', where = arglist)){\n  arglist$", o, " <- .betterExtract(arglist$", o, ", startEnv = myparent)\n }\n " )
  }
  func <- paste0(func, 'out <- do.call(', package,'::', funcName, ', arglist)\n ')
  if(!is.null(postProcessFunc)){
    func <- paste0(func, 'out <-', postProcessFunc, '(out)\n ')
  }
  func <- paste0(func, 'return(out)\n}')
  return(func)
}
