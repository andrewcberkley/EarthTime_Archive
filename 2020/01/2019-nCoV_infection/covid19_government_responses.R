#Covid-19 Country Lockdown Data from Oxford
setwd("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/01/2019-nCoV_infection/oxford_covid-19_government_response_tracker")

library(tidyverse)
library(httr)
library(jsonlite)
library(data.table)
library(reshape2)
library(dplyr)
library(zoo)
library(googledrive)
library(googlesheets4)

path <- paste0("https://covidtrackerapi.bsg.ox.ac.uk/api/stringency/date-range/2020-01-21/", format(Sys.time(), paste0("%Y", "-", "%m", "-", "%d")))
request <- GET(url = path)
response <- content(request, as = "text", encoding = "UTF-8")
jsondata <- fromJSON(response, flatten = TRUE) #%>% data.frame()
lst <- purrr::reduce(jsondata[3], dplyr::bind_rows)
df <- rbindlist(lst, fill = TRUE, idcol = "date")
long <- reshape2::melt(df, id.vars = c("date"))
long$variable <- as.character(long$variable) #https://stackoverflow.com/questions/44927537/meltreshape2-in-r-returning-values-as-factors/46774077
long$category <- rep_len(c("date_value", "country_code", "confirmed", "deaths", "stringency_actual", "stringency", "stringency_legacy", "stringency_legacy_disp"), length.out = nrow(long)) 
stringency <- long[grepl("stringency_actual", long$category),]
stringency <- stringency[,1:3]
colnames(stringency) <- c("date", "country_code", "stringency")
stringency$stringency <- as.character(stringency$stringency)
stringency$stringency <- as.numeric(stringency$stringency)

stringency <- stringency %>%
  group_by(country_code) %>%
  mutate(interp_stringent = na.approx(stringency, na.rm=FALSE)) 

stringency <- stringency[,c(1,2,4)]

wide <- stringency %>%
	group_by(date) %>%
	mutate(idx = row_number()) %>%
	spread(date, interp_stringent) %>%
	select(-idx)

colnames(wide) <- gsub("-", "", colnames(wide))

wide[wide==0] <- NA

wide_minus <- wide[,-c(1)]
wide_filled_over <- t(apply(wide_minus, 1, function(x) na.locf(x, fromLast = F, na.rm = F)))
wide_plus <- wide[,c(1)]
wide_final <- cbind(wide_plus, wide_filled_over)

write.csv(wide_final, paste0("OxCGRT_", format(Sys.time(), "%Y%m%d"), ".csv"), row.names = FALSE, na = "")

#as_id("https://docs.google.com/spreadsheets/d/1xNwdpAW1XzGc_AY40R1B1l2vMdGJhU-R8-Mse1wBXos/edit#gid=459159959")

#drive_update(as_id("https://docs.google.com/spreadsheets/d/1xNwdpAW1XzGc_AY40R1B1l2vMdGJhU-R8-Mse1wBXos/edit#gid=1291347643"), paste0("OxCGRT_", format(Sys.time(), "%Y%m%d"), ".csv"))

ss <- as_sheets_id("https://docs.google.com/spreadsheets/d/1xNwdpAW1XzGc_AY40R1B1l2vMdGJhU-R8-Mse1wBXos/edit#gid=1291347643")

sheet_write(wide_final, ss = ss, sheet = "Sheet1")

1

#The number "1" above in this code is meant to automatically respond to the following prompt:
# The googlesheets4 package is requesting access to your Google account. Select a pre-authorised account or enter '0' to obtain a new token. Press Esc/Ctrl + C to abort.
# 1: andrewcberkley@gmail.com