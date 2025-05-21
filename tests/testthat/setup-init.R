library(DSLite)
dslite.server1 <- newDSLiteServer(config = defaultDSConfiguration(include=c('dsMissForest')))
builder <- newDSLoginBuilder()
builder$append(server="server1", url='dslite.server1',driver = "DSLiteDriver")

logindata <- builder$build()
opals <- datashield.login(logins = logindata)
session1 <- dslite.server1$getSession(dslite.server1$getSessionIds())
data('iris', envir = session1)
