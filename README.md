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

... open and edit as needed the packages, then build and install them:

```
devtools::build('/mnt/shareddisk/workspace/dsWrappr_demo/dsImputation/')
devtools::build('/mnt/shareddisk/workspace/dsWrappr_demo/dsImputationClient/', manual = TRUE)
install.packages('/mnt/shareddisk/workspace/dsWrappr_demo/dsImputationClient_0.1.tar.gz', repos = NULL)
install.packages('/mnt/shareddisk/workspace/dsWrappr_demo/dsImputation_0.1.tar.gz', repos = NULL)
```
