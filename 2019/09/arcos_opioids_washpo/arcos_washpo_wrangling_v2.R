#THE OPIOID FILES
setwd(file.path(Sys.getenv('my_dir'),'2019/09/arcos_opioids_washpo/'))

#Drilling into the DEA’s pain pill database
#By The Washington Post Updated July 21, 2019

#For the first time, a database maintained by the Drug Enforcement Administration that tracks the path of every single pain pill sold in the United States — by manufacturers and distributors to pharmacies in every town and city — has been made public. The Washington Post sifted through nearly 380 million transactions from 2006 through 2012 that are detailed in the DEA’s database and analyzed shipments of oxycodone and hydrocodone pills, which account for three-quarters of the total opioid pill shipments to pharmacies. The Post is making this data available at the county and state levels in order to help the public understand the impact of years of prescription pill shipments on their communities.

#This is the World Economic Forum's interpretation of the data...

library(tidyverse)
library(data.table)

#Examining the preview file to see which columns will be needed to visualize in EarthTime
arcos_500_washpo <- read.delim("arcos_500_washpo.tsv", stringsAsFactors=FALSE)
#arcos_500_washpo <- readr::read_tsv("SplitExamples/aa", col_types = readr::cols())
df <- arcos_500_washpo[,c(7:10, 17:20, 24, 25, 31)]

##Bash scripting for managing the large file
#wc -l arcos_washpo
#awk '{ print $7, $8, $9, $10, $17, $18, $19, $20, $24, $25, $31 }' arcos_washpo >> arcos_washpo_subset

#df <- arcos_500_washpo
#Zip code clean up
df$REPORTER_ZIP <- sprintf("%05d", as.numeric(df$REPORTER_ZIP))
df$BUYER_ZIP <- sprintf("%05d", as.numeric(df$BUYER_ZIP))

#Date clean up
df$TRANSACTION_DATE <- sprintf("%08d", as.numeric(df$TRANSACTION_DATE))
df$MONTH <- substr(df$TRANSACTION_DATE, start = 1, stop = 2)
df$DAY <- substr(df$TRANSACTION_DATE, start = 3, stop = 4)
df$YEAR <- substr(df$TRANSACTION_DATE, start = 5, stop = 8)
df$YEARMONTH <- paste0(df$YEAR, df$MONTH)

#Summing the Quantities
matchTable <- data.table(date = rep(c("YEAR", "YEARMONTH"), each = 6), transactor = rep(c("BUYER", "REPORTER"), times = 6), area = rep(c("ZIP", "COUNTY", "STATE"), each = 2))
matchTable$transactor_area <- paste0(matchTable$transactor, "_", matchTable$area)
matchTable <- matchTable[,c(1,4)]
matchTable$listName <- paste0(matchTable$transactor_area, "_BY_", matchTable$date)

sum_the_quantities <- function(date, transactor_area){
	aggregate(list('quantity'=df[,"QUANTITY"]), by=list(date=df[,date],transactor_area=df[,transactor_area]), FUN=sum)
}

data <- Map(sum_the_quantities, matchTable$date, matchTable$transactor_area)
#namedData <- lapply(list(data), setNames, matchTable[,listName])
names(data) <- c("buyer_zip_by_year", "reporter_zip_by_year", "buyer_county_by_year", "reporter_county_by_year", "buyer_state_by_year", "reporter_state_by_year", "buyer_zip_by_yearmonth", "reporter_zip_by_yearmonth", "buyer_county_by_yearmonth", "reporter_county_by_yearmonth", "buyer_state_by_yearmonth", "reporter_state_by_yearmonth")


#Wrangling to wide format
earthTimeWideFormatting <- function(dfName){
	dfName %>%
    group_by(date) %>%
    mutate(idx = row_number()) %>%
    spread(date, quantity) %>%
    select(-idx)
}

dataWide <- lapply(data, function(x) earthTimeWideFormatting(x))

county2countyflowprep <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEAR,reporter_county=df$REPORTER_COUNTY,reporeter_state=df$REPORTER_STATE,buyer_county=df$BUYER_COUNTY,buyer_state=df$BUYER_STATE), FUN=sum)

state2stateflowprep <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEAR,reporeter_state=df$REPORTER_STATE,buyer_state=df$BUYER_STATE), FUN=sum)