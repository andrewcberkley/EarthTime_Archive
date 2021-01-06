#Tracking COVID-19 vaccination rates is crucial to understand the scale of protection against the virus, and how this is distributed across the global population.
#The following map and chart show the number of COVID-19 vaccination doses administered per 100 people within a given population. Note that this is counted as a single dose, and may not equal the total number of people vaccinated, depending on the specific dose regime (e.g. people receive multiple doses).

setwd("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/01/2019-nCoV_infection/owid_vaccinations_data/")

library(tidyverse)
library(data.table)
library(reshape2)
library(dplyr)
library(zoo)
library(googledrive)
library(googlesheets4)

owid_vaccinations <- read.csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv", stringsAsFactors = FALSE)

owid_vaccinations$iso_code[owid_vaccinations$location == "England"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Northern Ireland"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Scotland"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Wales"] <- "GBR"

owid_vaccinations <- owid_vaccinations[,c(2,3,6)]

wide <- owid_vaccinations %>%
  group_by(date) %>%
  mutate(idx = row_number()) %>%
  spread(date, total_vaccinations_per_hundred) %>%
  select(-idx)

cleaner_df <- setDT(wide)[, lapply(.SD, mean, na.rm=TRUE), by=iso_code]

#cleaner_df <- setDT(wide)[, lapply(.SD, function(x)
#  {x <- unique(x[!is.na(x)])
#  if(length(x) == 1) as.character(x)
#    else if(length(x) == 0) NA_character_
#    else "multiple"}),
#  by=iso_code]

colnames(cleaner_df) <- gsub("-", "", colnames(cleaner_df))

cleaner_df[cleaner_df=="NaN"] <- NA
cleaner_df[cleaner_df==0] <- NA

wide_minus <- cleaner_df[,-c(1)]
wide_filled_over <- t(apply(wide_minus, 1, function(x) na.locf(x, fromLast = F, na.rm = F)))
wide_plus <- cleaner_df[,c(1)]
wide_final <- cbind(wide_plus, wide_filled_over)

write.csv(wide_final, paste0("owid_vaccinations_", format(Sys.time(), "%Y%m%d"), ".csv"), row.names = FALSE, na = "")