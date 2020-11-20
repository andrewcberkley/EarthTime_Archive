#THE OPIOID FILES

#Drilling into the DEA’s pain pill database
#By The Washington Post Updated July 21, 2019

#For the first time, a database maintained by the Drug Enforcement Administration that tracks the path of every single pain pill sold in the United States — by manufacturers and distributors to pharmacies in every town and city — has been made public. The Washington Post sifted through nearly 380 million transactions from 2006 through 2012 that are detailed in the DEA’s database and analyzed shipments of oxycodone and hydrocodone pills, which account for three-quarters of the total opioid pill shipments to pharmacies. The Post is making this data available at the county and state levels in order to help the public understand the impact of years of prescription pill shipments on their communities.

#This is the World Economic Forum's interpretation of the data...

library(tidyverse)

#Examining the preview file to see which columns will be needed to visualize in EarthTime
#arcos_500_washpo <- read.delim("~/arcos_500_washpo.tsv", stringsAsFactors=FALSE)
arcos_500_washpo <- readr::read_tsv("SplitExamples/aa", col_types = readr::cols())
df <- arcos_500_washpo[,c(7:10, 17:20, 24, 25, 31)]

##Bash scripting for managing the large file
#wc -l arcos_washpo
#awk '{ print $7, $8, $9, $10, $17, $18, $19, $20, $24, $25, $31 }' arcos_washpo >> arcos_washpo_subset

#Zip code clean up
df$REPORTER_ZIP <- sprintf("%05d", as.numeric(df$REPORTER_ZIP))
df$BUYER_ZIP <- sprintf("%05d", as.numeric(df$BUYER_ZIP))

#Date clean up
df$TRANSACTION_DATE <- sprintf("%08d", as.numeric(df$TRANSACTION_DATE))
df$MONTH <- substr(df$TRANSACTION_DATE, start = 1, stop = 2)
df$DAY <- substr(df$TRANSACTION_DATE, start = 3, stop = 4)
df$YEAR <- substr(df$TRANSACTION_DATE, start = 5, stop = 8)
df$YEARMONTH <- paste0(df$YEAR, df$MONTH)

#Summing the Quanities
summed_arcos_buyer_zip_by_year <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEAR,buyer_zip_code=df$BUYER_ZIP), FUN=sum)
summed_arcos_reporter_zip_by_year <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEAR,reporter_zip_code=df$REPORTER_ZIP), FUN=sum)
summed_arcos_buyer_county_by_year <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEAR,buyer_county=df$BUYER_COUNTY), FUN=sum)
summed_arcos_reporter_county_by_year <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEAR,reporter_county=df$REPORTER_COUNTY), FUN=sum)
summed_arcos_buyer_state_by_year <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEAR,buyer_state=df$BUYER_STATE), FUN=sum)
summed_arcos_reporter_state_by_year <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEAR,reporter_state=df$REPORTER_STATE), FUN=sum)

summed_arcos_buyer_zip_by_yearmMonth <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEARMONTH,buyer_zip_code=df$BUYER_ZIP), FUN=sum)
summed_arcos_reporter_zip_by_yearMonth <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEARMONTH,reporter_zip_code=df$REPORTER_ZIP), FUN=sum)
summed_arcos_buyer_county_by_yearMonth <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEARMONTH,buyer_county=df$BUYER_COUNTY), FUN=sum)
summed_arcos_reporter_county_by_yearMonth <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEARMONTH,reporter_county=df$REPORTER_COUNTY), FUN=sum)
summed_arcos_buyer_state_by_yearMonth <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEARMONTH,buyer_state=df$BUYER_STATE), FUN=sum)
summed_arcos_reporter_state_by_yearMonth <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEARMONTH,reporter_state=df$REPORTER_STATE), FUN=sum)

#Wrangling to wide format
summed_data_frames <- lapply(ls(pattern="summed_arcos_"), function(x) get(x))

earthTimeWideFormatting <- function(dfName){
	dfName %>%
    group_by(date) %>%
    mutate(idx = row_number()) %>%
    spread(date, quantity) %>%
    select(-idx)
}

dataWide <- lapply(summed_data_frames, function(x) earthTimeWideFormatting(x))

county2countyflowprep <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEAR,reporter_county=df$REPORTER_COUNTY,reporeter_state=df$REPORTER_STATE,buyer_county=df$BUYER_COUNTY,buyer_state=df$BUYER_STATE), FUN=sum)

state2stateflowprep <- aggregate(list('quantity'=df$QUANTITY), by=list(date=df$YEAR,reporeter_state=df$REPORTER_STATE,buyer_state=df$BUYER_STATE), FUN=sum)