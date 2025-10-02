# dsWrappr
Automatic creation of client/server sets of datashield packages. 

Example: Create the dsImputation/dsImputationClient packages containing:
* the functions missForest, prodNA and mixError from the library missForest, 
* the functions kNN and aggr from the library VIM and
* the function data from the library utils
  
```
library(dsWrappr)

makePackage(packageName = 'dsImputation',                                       # new package name
            assignList = list(missForest = c('missForest', 'prodNA'),           # assign functions 
                              VIM = 'kNN'                                       # library = c(function1, function2) 
                              ),
            aggregateList = list(missForest = 'mixError',                       # aggregate functions 
                                 VIM = 'aggr',
                                 utils = 'data'
                                 ),
            symbols = list( missForest = 'xmis',                                # object names in the function arguments
                            prodNA = 'x',
                            mixError = c('ximp', 'xmis', 'xtrue'),
                            kNN = 'data',
                            aggr = 'x'
                            ),
            authors = 'person("...", "...", email = ..., role = c("aut", "cre"))',
            license = 'GPLv3',
            destPath = '/your/destination/path/')
```

... open and edit as needed the packages, especially the function aggrDS which is disclosive. Then build and install them:

```
devtools::build('/mnt/shareddisk/workspace/dsWrappr_demo/dsImputation/')
devtools::build('/mnt/shareddisk/workspace/dsWrappr_demo/dsImputationClient/', manual = TRUE)
install.packages('/mnt/shareddisk/workspace/dsWrappr_demo/dsImputationClient_0.1.tar.gz', repos = NULL)
install.packages('/mnt/shareddisk/workspace/dsWrappr_demo/dsImputation_0.1.tar.gz', repos = NULL)
```

Test:
```
library(dsBaseClient)
library(dsImputationClient)
library(VIM)
library(missForest)
library(DSLite)

help(package = 'dsImputationClient')

dslite.server1 <- newDSLiteServer(config = defaultDSConfiguration(include=c('dsBase', 'dsImputation')))
builder <- newDSLoginBuilder()
builder$append(server="server1", url='dslite.server1',driver = "DSLiteDriver")

logindata <- builder$build()
opals <- datashield.login(logins = logindata)
session1 <- dslite.server1$getSession(dslite.server1$getSessionIds())


opals <- datashield.login(logindata)

# load "iris" in the "remote" session
# data() works via its side effects and it breaks in conjunction with DSLite.
# In a normal, remote session ds.data('iris') would work.
data("iris")
session1$iris <- iris 

ds.summary('iris')
# make some holes in it:
ds.prodNA('iris', newObj = 'iris_na')
# local:
iris_na <- prodNA(iris)

# check :
ds.numNA('iris_na') # from dsBaseClient
# locally:
length(which(is.na(iris_na)))

# show:
p <- ds.aggr('iris_na')
# show locally:
VIM::aggr(iris_na)

# Impute:
ds.missForest('iris_na', newObj = 'iris_imp')
# the new data frame is in iris_imp$ximp
#recheck:
ds.numNA('iris_imp$ximp') # 
# show:
p <- ds.aggr('iris_imp$ximp')

# local equivalent:
iris_imp <- missForest(iris_na)
length(which(is.na(iris_imp$ximp)))
VIM::aggr(iris_imp$ximp)

# compute imputation error:
ds.mixError(ximp = 'iris_imp$ximp', xmis = 'iris_na', xtrue = 'iris')
#local:
mixError(ximp = iris_imp$ximp, xmis = iris_na, xtrue = iris)


# impute with VIM::kNN
ds.kNN('iris_na', newObj = 'iris_knn', imp_var = FALSE)  # imp_var - impute columns in place

# compute its error:
 ds.mixError(ximp = 'iris_knn', xmis = 'iris_na', xtrue = 'iris')

# the differences between the 2 methods:

 ds.mixError(ximp = 'iris_knn', xmis = 'iris_na', xtrue = 'iris_imp$ximp')

# There's more, I can use pipes with all this:

   ds.data('iris') |>
   sapply(ds.prodNA, 'iris_na') |> # sapply because ds.data returns a list (one element per remote node)
   ds.missForest('iris_new') |>
   paste0('$ximp') |>   # the imputed dataframe is the 'ximp' element
   ds.mixError(xmis = 'iris_na', xtrue='iris')

```
As mentioned, the generated aggrDS function is disclosive as it returns the whole original data (iris in the example above). Below, an example of a modified function that masks the data but still allows the plot:

```
aggrDS <- function (...) 
{
    argList <- list(...)
    myEnv <- parent.frame()
    argNames <- names(argList)
    if (is.null(argNames)) {
        argNames <- rep("", length(argList))
    }
    argList <- Map(function(name, value) {
        retval <- .decode.arg(value)
        if (name %in% c("x")) {
            retval <- .deep.extract(retval, startEnv = myEnv)
        }
        return(retval)
    }, argNames, argList)
    val <- do.call(VIM::aggr, argList, envir = myEnv)
    ####### MASK THE ORIGINAL INPUT ##################################### 
    val$x <- data.frame(apply(val$x, 2, .maskAggrData, simplify = FALSE))
    #####################################################################
    return(val)
}


.maskAggrData <- function (col) 
{
    if (is.factor(col)) {
        levels(col) <- c(levels(col), "*")
    }
    col[!is.na(col)] <- "*"
    col
}

```


