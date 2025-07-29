
.encode.arg <- function(some.object, serialize.it = FALSE){

if(serialize.it){
  encoded <- paste0(RCurl::base64Encode(jsonlite::serializeJSON(some.object)), 'serialized')
} else {
  encoded <- RCurl::base64Encode(jsonlite::toJSON(some.object, null = 'null'))
}
  # go fishing for '+', '/' and '=', opal rejects them :
  my.dictionary <- c('\\/' = '-slash-', '\\+' = '-plus-', '\\=' = '-equals-')
  sapply(names(my.dictionary), function(x){
    encoded[1] <<- gsub(x, my.dictionary[x], encoded[1])
  })
  return(paste0(encoded[1],'base64'))

}

.decode.arg <- function(some.thing, simplifyMatrix = FALSE){

  if(length(some.thing) == 1 && grepl('base64', some.thing, ignore.case = TRUE)){
    some.thing <- gsub('base64', '', some.thing, ignore.case =TRUE)
    serialized <- FALSE
    if(grepl('serialized', some.thing, ignore.case = TRUE)){
      serialized <- TRUE
      some.thing <- gsub('serialized', '', some.thing, ignore.case =TRUE)
    }
    my.dictionary = c('-plus-' = '+', '-slash-' = '/', '-equals-' = '=')
    sapply(names(my.dictionary), function(x){
      some.thing <<- gsub(x, my.dictionary[x], some.thing)
    })
    #
    if(serialized){
      some.thing <- jsonlite::unserializeJSON(RCurl::base64Decode(some.thing))
    } else {
      some.thing <- jsonlite::fromJSON(RCurl::base64Decode(some.thing), simplifyMatrix = simplifyMatrix)
    }
  }
  return(some.thing)
}


