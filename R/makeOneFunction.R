makeOneFunction <- function(package, funcName, funcType = c('aggregate','assign'), clientPrefix, serverSuffix , symbols = NULL, assignVar = NULL ){
  func <- list()
### client
  if (length(funcType) != 1 ){
    stop('funcType must be one of "aggregate" and "assign"')
  }
  serverFuncName <- paste0(funcName, serverSuffix)
  clientFuncName <- paste0(clientPrefix, funcName)
  clientFuncText <- paste(readLines(system.file('client', 'function_template.md', package='dsWrappr')), collapse = "\n")
  if(funcType == 'assign' ){
    if(is.null(assignVar)){
      assignVar <- 'newObj'
    }
  }

  dict <- list(assign = c("@clientFunction" = clientFuncName, "@assignVar" = assignVar,
                          "@serverFunction" = serverFuncName, "@op" = "assign", "@retVal" = assignVar,
                          "@origFuncName" = funcName, "@packageName" = package,
                          "(?s)@beginAssignVar(.+?)@endAssignVar" = "\\1"),
               aggregate = c("@clientFunction" = clientFuncName, "@assignVar.*?, " = "",
                             "@serverFunction" = serverFuncName,"@op" = "aggregate", "@retVal" = "ret",
                             "@origFuncName" = funcName, "@packageName" = package,
                             "(?s)@beginAssignVar(.+?)@endAssignVar" = ""))
  if(length(symbols) > 0 ){
    dict$assign["@firstArg"] <- dict$aggregate["@firstArg"] <- symbols[1]
    dict$assign["@beginFirstArg(.+?)@endFirstArg"] <- dict$aggregate["@beginFirstArg(.+?)@endFirstArg"] <- "\\1"
  } else {
    dict$assign["@firstArg.*?, "] <-  dict$aggregate["@firstArg.*?, "] <- ""
    dict$assign["@beginFirstArg(.+?)@endFirstArg"] <- dict$aggregate["@beginFirstArg(.+?)@endFirstArg"] <- ""
  }

  func$client <- stringr::str_replace_all(clientFuncText, dict[[funcType]])


  ### server
  serverFuncText <- paste(readLines(system.file('server', 'function_template.md', package='dsWrappr')), collapse = "\n")
  printSyms <- ""
  symbolClause <- ""
  if(length(symbols) > 0 ){
    printSyms <- paste0("'",paste(symbols, collapse = "', '"),"'")
    symbolClause <- "\\1"
  }

  func$server <- stringr::str_replace_all(serverFuncText,
                                          c("@serverFunction" = serverFuncName,"@symbolList" = printSyms,
                                            "(?s)@beginSymbolClause(.+?)@endSymbolClause" = symbolClause,
                                            "@packageName" = package, "@functionName" = funcName))

  return(func)
}
