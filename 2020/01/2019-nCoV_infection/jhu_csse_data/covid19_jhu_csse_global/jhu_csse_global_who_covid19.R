setwd("C:/Users/ABERK/Box/Data_Science_Exploration/ABERK/ABERK_Archive/EarthTime_Archive/2020/01/2019-nCoV_infection/jhu_csse_data/covid19_jhu_csse_global/")

library(tibble)
library(tidyverse)
library(googledrive)
library(googlesheets4)

covid19_global_ts <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv", stringsAsFactors = FALSE)
iso3_lookup <- read.csv("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/01/2019-nCoV_infection/jhu_csse_data/covid19_jhu_csse_global/UID_ISO_FIPS_LookUp_Table_ABERK.csv", stringsAsFactors = FALSE)

covid19_global_ts$Country.Region <- ifelse(grepl("Anguilla|Aruba|Bermuda|Bonaire, Sint Eustatius and Saba|British Virgin Islands|Cayman Islands|Channel Islands|Curacao|Falkland Islands (Malvinas)|Faroe Islands|French Guiana|French Polynesia|Gibraltar|Greenland|Guadeloupe|Hong Kong|Isle of Man|Macau|Martinique|Mayotte|Montserrat|New Caledonia|Reunion|Saint Barthelemy|Saint Pierre and Miquelon|Sint Maarten|St Martin|Turks and Caicos Islands", covid19_global_ts$Province.State), covid19_global_ts$Province.State, covid19_global_ts$Country.Region)

covid19_global_ts <- covid19_global_ts[,-c(1,3,4)]

covid19_global_ts_v2 <- covid19_global_ts %>% 
  group_by(Country.Region) %>% 
  #summarise_if(is.numeric, funs(sum)) #Warning message: funs() is soft deprecated as of dplyr 0.8.0 Please use a list of either functions or lambdas:   # Auto named with `tibble::lst()`:  tibble::lst(mean, median)
  summarise_if(is.numeric, tibble::lst(sum))

covid19_global_ts_v2 <- add_column(covid19_global_ts_v2, covid19_global_ts_v2[,2], .after = "Country.Region", .name_repair = make.names)
colnames(covid19_global_ts_v2)[2] <- "X1.21.20_sum"

destroyX = function(df) {
#https://stackoverflow.com/questions/10441437/why-am-i-getting-x-in-my-column-names-when-reading-a-data-frame
  f = df
  for (col in c(1:ncol(f))){ #for each column in dataframe
    if (startsWith(colnames(f)[col], "X") == TRUE)  { #if starts with 'X' ..
      colnames(f)[col] <- substr(colnames(f)[col], 2, 100) #get rid of it
    }
  }
  assign(deparse(substitute(df)), f, inherits = TRUE) #assign corrected data to original name
}

destroyX(covid19_global_ts_v2)

colnames(covid19_global_ts_v2) <- gsub("_sum", "", colnames(covid19_global_ts_v2))
colnames(covid19_global_ts_v2) <- gsub("\\.", "/", colnames(covid19_global_ts_v2))
colnames(covid19_global_ts_v2) <- strptime(colnames(covid19_global_ts_v2), "%m/%d/%Y")
colnames(covid19_global_ts_v2) <- gsub("0020-", "2020-", colnames(covid19_global_ts_v2))
colnames(covid19_global_ts_v2) <- gsub("0020-", "2020-", colnames(covid19_global_ts_v2)) #update for 2021
colnames(covid19_global_ts_v2) <- gsub("\\-", "", colnames(covid19_global_ts_v2))
colnames(covid19_global_ts_v2)[1] <- "Country_Region"

covid19_global_ts_v3 <- covid19_global_ts_v2

covid19_global_ts_v3$Country_Region <- iso3_lookup$iso3[match(covid19_global_ts_v3$Country_Region, iso3_lookup$Country)]
colnames(covid19_global_ts_v3)[1] <- "ISO3"

covid19_global_ts_v3[covid19_global_ts_v3==0] <- NA

#sum(covid19_global_ts_v2[,ncol(covid19_global_ts_v2)])

print(paste0("The number of COVID-19 cases globally has now reached ", sum(covid19_global_ts_v2[,ncol(covid19_global_ts_v2)]), " as reported by the World Health Organization as of ", Sys.time(), " according to JHU CSSE data."))

ss <- as_sheets_id("https://docs.google.com/spreadsheets/d/1SGCBoYuLU9ETE_Ng9qCOXUFKTQxF-BAl0VdIOcpJhGU/edit#gid=1572974231")

sheet_write(covid19_global_ts_v3, ss = ss, sheet = "Copy of Sheet1")

1

#The number "1" above in this code is meant to automatically respond to the following prompt:
# The googlesheets4 package is requesting access to your Google account. Select a pre-authorised account or enter '0' to obtain a new token. Press Esc/Ctrl + C to abort.
# 1: andrewcberkley@gmail.com