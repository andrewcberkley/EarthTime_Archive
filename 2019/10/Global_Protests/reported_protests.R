
# protestts.R
#
# Sets up some basic time series plots and diagnostics for the
# countries with the most reported protests in GDELT
#
# 20130928: Initial version
#
# Patrick T. Brandt
# University of Texas Dallas
#
#
# Read in the libraries and the data
library(xts)
# Get this file at
# http://gdeltblog.wordpress.com/2013/07/14/reading-gdelt-subsets-into-r/
source("read.gdelt.R")
# Read in the data: this takes a while.
system.time(dd <- read.gdelt("protest_data.csv"))
################################################
# Now make protest time series by country codes
################################################
sortedcountries <- rev(sort(table(dd$ActionGeo_CountryCode)))
fullts <- zoo(,seq(as.Date("1979-1-1"), as.Date("2013-8-18"),
 by="day"))
# Start with the top 50
for(i in 1:50)
{
 cty <- names(sortedcountries[i])
 tmp <- subset(dd, ActionGeo_CountryCode==cty, select=SQLDATE)
 tmp <- data.frame(dt=tmp, ev=rep(1, length(tmp)))
 out <- aggregate(tmp[,2], by=list(tmp[,1]), sum)
 colnames(out) <- c("dt", cty)
 out <- xts(out[,2], out[,1])
 fullts <- merge(fullts, as.zoo(out), fill=0)
cat("Finished country ", i, cty, "\n")
}
# Now set up names via data on FIPS-10-4 codes from
# http://earth-info.nga.mil/gns/html/gazetteers2.html
# Have made the Excel spreadsheet into a CSV file
#
realnames <- read.csv("GEOPOLITICAL_CODES.csv", header=TRUE)
ccodes <- names(sortedcountries[1:50])
ccodes[9] <- "Unknown"
cnames <- vector(length=50, mode="character")
for(i in 1:8) { cnames[i] <-
 as.character(realnames[realnames$Code==ccodes[i],
 4]) }
cnames[9] <- "UNKNOWN"
for(i in 10:32) { cnames[i] <- as.character(realnames[realnames$Code==ccodes[i], 4]) }
cnames[33] <- "SERBIA"
for(i in 34:50) { cnames[i] <- as.character(realnames[realnames$Code==ccodes[i], 4]) }
colnames(fullts) <- cnames
write.csv(fullts, file="fullts.csv", row.names=as.character(index(fullts)))
# Now plot top 40
fullts <- read.csv("fullts.csv")
library(zoo)
fullts <- zoo(fullts[,2:51], as.Date(fullts[,1]))
png(file="globalprotests19792013.png", units="in", width=8, height=8, res=300)
par(mfcol=c(8,5), mai=c(0.25, 0.25, 0.25, 0.1), cex=0.45, omi=c(0,0,0.4,0))
for(i in 1:40)
{
 plot(aggregate(fullts[,i], as.yearmon, sum), xlab="", ylab="", main=colnames(fullts)[i])
}
mtext("Top 40 Protest Countries: Where and When 76% of Global Monthly Protests Occur, 1979-2013\n @PatrickTBrandt",
 outer=TRUE)
dev.off()

par(mfcol=c(8,5), mai=c(0.25, 0.25, 0.25, 0.1), cex=0.45, omi=c(0,0,0.4,0))
for(i in 1:40)
{
 acf(aggregate(fullts[,i], as.yearmon, sum), xlab="", ylab="", main=colnames(protestsnormed)[i])
}
mtext("ACFs of protests, 1979-2013\n @PatrickTBrandt",
 outer=TRUE)
# Get the normalizing factors
# Get the normaling factors from https://github.com/johnb30/eventscale
# Set up norm data
normfactors <- read.table("eventscale-master/data/daily_scale_monadic.csv")
colnames(normfactors) <- c("date", "country", "count")
# Some time series massaging
dts <- as.Date(as.character(normfactors[,1]), format="%Y%m%d")
normfactors$date <- dts
# Object to hold the normalized time series
normts <- zoo(,seq(min(range(dts)),max(range(dts)),
 by="day"))
# Get the top 50 countries normalizing factors
for(i in 1:50)
{
 # Get the country we want
 cty <- names(sortedcountries[i])
 dta <- normfactors[normfactors$country==cty,]
 tmp <- xts(dta[,3], dta[,1])
 colnames(tmp) <- cty
 normts <- merge(normts, as.zoo(tmp), fill=0)
 cat("Finished country ", i, cty, "\n")
}

# Set up a normed top 40
fullts40 <- fullts[,c(1:8,10:41)]
norm40 <- normts[,1:40]
# Do the norming (add 1 to denominator to cover dates when there are
# no events recorded)
protestsnormed <- as.xts(fullts40/(norm40+1))
# Now plot normed protests for 1979(1)-2013(5)
out <- protestsnormed['/2013-05-30']
# Normalized protest plot
png(file="normalizedglobalprotests19792013.png", units="in", width=8, height=8, res=300)
par(mfcol=c(8,5), mai=c(0.25, 0.25, 0.25, 0.1), cex=0.45, omi=c(0,0,0.4,0))
for(i in 1:40)
{
 plot(aggregate(out[,i], as.yearmon, sum), xlab="", ylab="", main=colnames(protestsnormed)[i])
}
mtext("Normalized protests, 1979(1)-2013(5)\n @PatrickTBrandt",
 outer=TRUE)
dev.off()
# ACFs of the normalized protests
png(file="acfsnormalizedglobalprotests19792013.png", units="in", width=8, height=8, res=300)
par(mfcol=c(8,5), mai=c(0.25, 0.25, 0.25, 0.1), cex=0.45, omi=c(0,0,0.4,0))
for(i in 1:40)
{
 acf(aggregate(out[,i], as.yearmon, sum), xlab="", ylab="", main=colnames(protestsnormed)[i])
}
mtext("ACFs of Normalized protests, 1979-2013\n @PatrickTBrandt",
 outer=TRUE)
dev.off()
# Now, filter / detrend the raw protest counts
library(mFilter)
Ymonthly <- aggregate(fullts, as.yearmon, sum)[,c(1:8,10:41)]
library(snow)
cl <- makeCluster(spec=16, type="SOCK")
clusterEvalQ(cl, library(mFilter))
# Parallel func. for HP
hp <- function(i, Y)
{
 hpfilter(Y[,i], freq=12, type="frequency")
}
system.time(fd <- clusterApplyLB(cl, 1:ncol(Ymonthly), hp, Y=Ymonthly))
stopCluster(cl)
# Now let's plot the cycles
png(file="hpnormalizedglobalprotests19792013.png", units="in", width=8, height=8, res=300)
par(mfcol=c(8,5), mai=c(0.25, 0.25, 0.25, 0.1), cex=0.45, omi=c(0,0,0.4,0))
for(i in 1:length(fd))
{
 tmp <- ts(fd[[i]]$cycle, start=c(1979,1), freq=12)
 plot(tmp, main=colnames(Ymonthly)[i])
}
mtext("Hodrick-Prescott filtered protests, 1979(1)-2013(8)\n @PatrickTBrandt",
 outer=TRUE)
dev.off()

png(file="acfsHPnormalizedglobalprotests19792013.png", units="in",
 width=8, height=8, res=300)
par(mfcol=c(8,5), mai=c(0.25, 0.25, 0.25, 0.1), cex=0.45, omi=c(0,0,0.4,0))
for(i in 1:length(fd))
{
 tmp <- ts(fd[[i]]$cycle, start=c(1979,1), freq=12)
 acf(tmp, main=colnames(Ymonthly)[i])
}
par(mfcol=c(8,5), mai=c(0.25, 0.25, 0.25, 0.1), cex=0.45, omi=c(0,0,0.4,0))
mtext("ACFs of HP filtered protests, 1979(1)-2013(8)\n @PatrickTBrandt",
 outer=TRUE)
dev.off()