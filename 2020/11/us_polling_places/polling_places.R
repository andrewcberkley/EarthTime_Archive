setwd("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/11/us_polling_places/")

library(data.table)
library(stringi)
library(tidyverse)

#Get the files names
polls_2012 <- list.files("state_data", full.names = T, recursive = T, pattern = ".*2012.csv")
polls_2014 <- list.files("state_data", full.names = T, recursive = T, pattern = ".*2014.csv")
polls_2016 <- list.files("state_data", full.names = T, recursive = T, pattern = ".*2016.csv")
polls_2018 <- list.files("state_data", full.names = T, recursive = T, pattern = ".*2018.csv")
#polls_2012_2018 <- list.files("state_data", full.names = T, recursive = T, pattern = ".*.csv")

#Convert the .csv files into one data.frame using `rbindlist`
df_2012 = as.data.frame(rbindlist(lapply(polls_2012, fread), fill = TRUE))
df_2014 = as.data.frame(rbindlist(lapply(polls_2014, fread), fill = TRUE))
df_2016 = as.data.frame(rbindlist(lapply(polls_2016, fread), fill = TRUE))
df_2018 = as.data.frame(rbindlist(lapply(polls_2018, fread), fill = TRUE))
#df_2012_2018 = as.data.frame(rbindlist(lapply(polls_2012_2018, fread), fill = TRUE))

df_2012[1] <- 2012
df_2014[1] <- 2014
df_2016[1] <- 2016
df_2018[1] <- 2018

df_2012_clean <- df_2012[,c(1,2,8)]
df_2014_clean <- df_2014[,c(1,2,8)]
df_2016_clean <- df_2016[,c(1,2,8)]
df_2018_clean <- df_2018[,c(1,2,8)]

merged_election_years <- do.call("rbind", list(df_2012_clean, df_2014_clean, df_2016_clean, df_2018_clean))

rm(list=setdiff(ls(), "merged_election_years"))

#df <- df_2012[grep("AZ|NC|OH|PA|VA|WI", df_2012$state),]
battleground_df <- merged_election_years[grep("AZ|NC|OH|PA|VA|WI", merged_election_years$state),]

year_state_zipcode <- battleground_df

#https://stackoverflow.com/questions/50337189/remove-everything-before-the-last-space
year_state_zipcode[3] <- stri_extract_last_regex(year_state_zipcode$address, "\\S+")
year_state_zipcode[3] <- sub('\\-.*', '', year_state_zipcode$address)
colnames(year_state_zipcode) <- c("year", "state", "zip_code")

year_state_zipcode["number_of_polls"] <- 1

aggregated_polls <- year_state_zipcode %>% 
  group_by(year, state, zip_code) %>% 
  summarize_all(sum)

zip_lat_long <- read.csv("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/11/us_polling_places/us-zip-code-latitude-and-longitude.csv", sep=";")

zip_lat_long <- zip_lat_long[,c(1,4,5)]

aggregated_polls$latitude <- zip_lat_long$Latitude[match(aggregated_polls$zip_code, zip_lat_long$Zip)]

aggregated_polls$longitude <- zip_lat_long$Longitude[match(aggregated_polls$zip_code, zip_lat_long$Zip)]

aggregated_polls_clean <- aggregated_polls[complete.cases(aggregated_polls), ]

wide_df <- aggregated_polls_clean %>%
  group_by(year, state, zip_code, latitude, longitude) %>%
  mutate(idx = row_number()) %>%
  spread(year, number_of_polls) %>%
  select(-idx)

wide_df[is.na(wide_df)] <- 0

write.csv(wide_df, "polling_places_2012_2018_NC_OH_PA_VA_WI.csv", row.names = FALSE, na = "")