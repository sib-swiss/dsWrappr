library(DSLite)
library(dsBase)
library(dsBaseClient)
#pkgload::load_all('<server_package_path>')
#dslite.server1 <- newDSLiteServer(config = defaultDSConfiguration(include=c('dsBase', '<server_package>')))
#dslite.server2 <- newDSLiteServer(config = defaultDSConfiguration(include=c('dsBase', '<server_package>')))

#library(DSI)
#library(dsBaseClient)



builder <- newDSLoginBuilder()
builder$append(server="server1", url='dslite.server1',driver = "DSLiteDriver")
builder$append(server="server2", url='dslite.server2',driver = "DSLiteDriver")

logindata <- builder$build()


opals <- datashield.login(logins = logindata)
session1 <- dslite.server1$getSession(dslite.server1$getSessionIds())
session2 <- dslite.server2$getSession(dslite.server2$getSessionIds())
data('iris', envir = session1)

