setwd("C:/Users/ABERK/Box/Data_Science_Exploration/ABERK/ABERK_Archive/EarthTime_Archive/2019/10/California_Power_Outages/")

library(anytime)
library(tidyverse)

outages_expanded <- read.csv("C:/Users/ABERK/Box/Data_Science_Exploration/ABERK/ABERK_Archive/EarthTime_Archive/2019/10/California_Power_Outages/outages_expanded.csv", stringsAsFactors=FALSE)

outages_expanded$earliest <- anytime(outages_expanded$earliest)
outages_expanded$latest <- anytime(outages_expanded$latest)

outages_expanded$year <- substr(outages_expanded$earliest, start = 1, stop = 4)
outages_expanded$month <- substr(outages_expanded$earliest, start = 6, stop = 7)
outages_expanded$day <- substr(outages_expanded$earliest, start = 9, stop = 10)

outages_expanded$date <- paste0(outages_expanded$year, outages_expanded$month, outages_expanded$day)

outages_expanded <- outages_expanded[,-c(2, 3, 4, 6, 7, 12:14)]
outages_expanded <- outages_expanded[, c(1, 4:7, 2, 3)]

earthtime_format_df <- outages_expanded %>%
  group_by(date) %>%
  mutate(idx = row_number()) %>%
  spread(date, max_estCustAffected) %>%
  select(-idx)

write.csv(earthtime_format_df, "poweroutages_pre_upload.csv", na = "", row.names = FALSE)