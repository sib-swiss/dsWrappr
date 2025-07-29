makeOneFunction <- function(package, funcName, funcType = c('aggregate','assign'), serverSuffix , symbols = NULL, assignVar = NULL ){
  func <- list()
### client
  if (length(funcType) != 1 ){
    stop('funcType must be one of "aggregate" and "assign"')
  }
  serverFuncName <- paste0(funcName, serverSuffix)
  clientFuncText <- readLines(system.file('client', 'function_template.md', package='dsWrapR'))
  if(funcType == 'assign' ){
    if(is.null(assignVar)){
      assignVar <- 'newObj'
    }
  }
  dict <- list(assign = c("@assignVar" = assignVar, "@serverFunction" = serverFuncName, "@op" = "assign", "@retVal" = assignVar),
               aggregate = c("@assignVar," = NULL, "@serverFunction" = serverFuncName, "@op" = "aggregate", "@retVal" = "ret"))

  func$client <- stringr::str_replace_all(clientFuncText, dict[[funcType]])


  ### server
  serverFuncText <- readLines(system.file('server', 'function_template.md', package='dsWrapR'))
  if(length(symbols > 0 )){
    printSyms <- paste(symbols, collapse = "', '")
  }
  func$server <- stringr::str_replace_all(serverFuncText, c("@symbolList" = printSyms, "@packageName" = package, "@funcName" = funcName))

  return(func)
}
