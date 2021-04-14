setwd(file.path(Sys.getenv('my_dir'),'2020/01/2019-nCoV_infection/jhu_csse_data/covid19_jhu_csse_china/'))

library(tibble)
library(tidyverse)
library(googledrive)
library(googlesheets4)

covid19_jhu_china <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv", stringsAsFactors = FALSE)

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

destroyX(covid19_jhu_china)

covid19_china_proviences <- dplyr::filter(covid19_jhu_china, grepl("China|Taiwan*", Country.Region))

covid19_china_proviences[34,1] <- "Taiwan"

covid19_china_proviences <- covid19_china_proviences[,-c(2:4)]

covid19_china_proviences <- add_column(covid19_china_proviences, `1.21.20` = 0, .after = "Province.State")

colnames(covid19_china_proviences) <- gsub("\\.", "/", colnames(covid19_china_proviences))

colnames(covid19_china_proviences) <- strptime(colnames(covid19_china_proviences), "%m/%d/%Y")

colnames(covid19_china_proviences) <- gsub("0020-", "2020-", colnames(covid19_china_proviences))

colnames(covid19_china_proviences) <- gsub("0021-", "2021-", colnames(covid19_china_proviences)) #new year update

colnames(covid19_china_proviences) <- gsub("\\-", "", colnames(covid19_china_proviences))

colnames(covid19_china_proviences)[1] <- "NAME_1"

covid19_china_proviences$NAME_1[covid19_china_proviences$NAME_1 == "Inner Mongolia"] <- "Nei Mongol"
covid19_china_proviences$NAME_1[covid19_china_proviences$NAME_1 == "Ningxia"] <- "Ningxia Hui"
covid19_china_proviences$NAME_1[covid19_china_proviences$NAME_1 == "Tibet"] <- "Xizang"
covid19_china_proviences$NAME_1[covid19_china_proviences$NAME_1 == "Xinjiang"] <- "Xinjiang Uygur"

covid19_china_proviences <- covid19_china_proviences[order(covid19_china_proviences$NAME_1),]

covid19_china_proviences[covid19_china_proviences==0] <- NA
covid19_china_proviences[14,2] <- 347

write.csv(covid19_china_proviences, paste0("covid19_china_jhu_csse_", format(Sys.time(), "%Y%m%d"), ".csv"), row.names = FALSE, na = "")

#drive_update(as_id("https://docs.google.com/spreadsheets/d/1l5YMJv8ZTEYc53n-cJuLYM4xDERLC-mEudNNQgbt-tM/edit#gid=182512028"), paste0("covid_nytimes_", format(Sys.time(), "%Y%m%d"), ".csv"))

ss <- as_sheets_id("https://docs.google.com/spreadsheets/d/1MhaS-uxUQ3C7lO2TAEKTkL8MD-o7xyomeAvuP1CMe_4/edit#gid=2133865741")

sheet_write(covid19_china_proviences, ss = ss, sheet = "covid-19_china_ provincial confirmed cases.csv")

1

#The number "1" above in this code is meant to automatically respond to the following prompt:
# The googlesheets4 package is requesting access to your Google account. Select a pre-authorised account or enter '0' to obtain a new token. Press Esc/Ctrl + C to abort.
# 1: andrewcberkley@gmail.com

rm(list = ls())
.rs.restartR()