#Tracking COVID-19 vaccination rates is crucial to understand the scale of protection against the virus, and how this is distributed across the global population.
#The following map and chart show the number of COVID-19 vaccination doses administered per 100 people within a given population. Note that this is counted as a single dose, and may not equal the total number of people vaccinated, depending on the specific dose regime (e.g. people receive multiple doses).

setwd(file.path(Sys.getenv('my_dir'),'2021/02/Vaccinations/'))

library(tidyverse)
library(data.table)
library(reshape2)
library(dplyr)
library(zoo)
library(googledrive)
library(googlesheets4)

owid_vaccinations <- read.csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv", stringsAsFactors = FALSE)

#vaccinations_attitudes <- read.csv("https://github.com/YouGov-Data/covid-19-tracker/tree/master/data", stringsAsFactors = FALSE)


owid_vaccinations$iso_code[owid_vaccinations$location == "England"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Northern Ireland"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Scotland"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Wales"] <- "GBR"

#owid_list <- list()

#owid_list[[1]] <- owid_vaccinations[,c(2,3,9)] #total_vaccinations_per_100
#owid_list[[2]] <- owid_vaccinations[,c(2,3,12)] #daily_vaccinations_per_million
#owid_list[[3]] <- owid_vaccinations[,c(2,3,6)] #full_vaccination_percentage

total_vaccinations_per_100 <- owid_vaccinations[,c(2,3,9)]
daily_vaccinations_per_million <- owid_vaccinations[,c(2,3,12)]
full_vaccination_percentage <- owid_vaccinations[,c(2,3,6)]


wide <- owid_vaccinations %>%
  group_by(date) %>%
  mutate(idx = row_number()) %>%
  spread(date, total_vaccinations_per_hundred) %>%
  select(-idx)

cleaner_df <- setDT(wide)[, lapply(.SD, mean, na.rm=TRUE), by=iso_code]

colnames(cleaner_df) <- gsub("-", "", colnames(cleaner_df))

cleaner_df[cleaner_df=="NaN"] <- NA
cleaner_df[cleaner_df==0] <- NA

wide_minus <- cleaner_df[,-c(1)]
wide_filled_over <- t(apply(wide_minus, 1, function(x) na.locf(x, fromLast = F, na.rm = F)))
wide_plus <- cleaner_df[,c(1)]
wide_final <- cbind(wide_plus, wide_filled_over)

#write.csv(wide_final, paste0("owid_vaccinations_", format(Sys.time(), "%Y%m%d"), ".csv"), row.names = FALSE, na = "")

#Data Citations:
#Hasell, J., Mathieu, E., Beltekian, D. et al. A cross-country database of COVID-19 testing. Sci Data 7, 345 (2020). https://doi.org/10.1038/s41597-020-00688-8
#Jones, Sarah P., Imperial College London Big Data Analytical Unit and YouGov Plc. 2020, Imperial College London YouGov Covid Data Hub, v1.0, YouGov Plc, April 2020

#ss <- as_sheets_id("https://docs.google.com/spreadsheets/d/1a_GBckfFUWN209D7wiXVUvtSy44-wXIE7BjbHB7lv3E/edit#gid=1175349253")

#sheet_write(wide_final, ss = ss, sheet = "Sheet1")

1

#The number "1" above in this code is meant to automatically respond to the following prompt:
# The googlesheets4 package is requesting access to your Google account. Select a pre-authorised account or enter '0' to obtain a new token. Press Esc/Ctrl + C to abort.
# 1: andrewcberkley@gmail.com