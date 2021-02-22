setwd(file.path(Sys.getenv('my_dir'),'2020/01/2019-nCoV_infection/nytimes_covid_data/'))

library(tibble)
library(tidyverse)
library(data.table)
library(googledrive)
library(googlesheets4)

nytimes_covid <- read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv")

fips_centroids <- read.csv(file.path(Sys.getenv('my_dir'),'2020/01/2019-nCoV_infection/us_county_centroids.csv'))

nytimes_covid$fips[nytimes_covid$county == "New York City"] <- 36061
nytimes_covid$fips[nytimes_covid$state == "Guam"] <- "GU"
nytimes_covid$fips[nytimes_covid$state == "Virgin Islands"] <- "VI"
nytimes_covid$fips[nytimes_covid$state == "Puerto Rico"] <- "PR"


nytimes_covid_cases <- nytimes_covid[,-c(6)]

nytimes_covid_cases$latitude <- fips_centroids$lat[match(nytimes_covid_cases$fips, fips_centroids$fips)]

nytimes_covid_cases$longitude <- fips_centroids$lon[match(nytimes_covid_cases$fips, fips_centroids$fips)]

covid_wide <- nytimes_covid_cases %>%
  group_by(date) %>%
  mutate(idx = row_number()) %>%
  spread(date, cases)%>%
  select(-idx)

covid_clean <- setDT(covid_wide)[, lapply(.SD, function(x)
  {x <- unique(x[!is.na(x)])
  if(length(x) == 1) as.character(x)
  else if(length(x) == 0) NA_character_
  else "multiple"}),
  by=fips]

colnames(covid_clean) <- gsub("-", "", colnames(covid_clean))

covid_clean <- covid_clean[!(covid_clean$state=="multiple")]

covid_final <- covid_clean[,-c(2:3)]

# write.csv(output, paste0("C://Users/My Computer/dir", format(Sys.time(), "%d-%b-%Y %H.%M"), ".csv"))

# write.csv(covid_final, "covid_nytimes_20200330.csv", row.names = FALSE, na = "")

covid_final <- as.data.frame(covid_final)

covid_final$today <- covid_final[,ncol(covid_final)]

#colnames(covid_final)[ncol(covid_final)] <- paste0(format(Sys.Date()-1, "%Y%m%d"))
colnames(covid_final)[ncol(covid_final)] <- paste0(format(Sys.Date(), "%Y%m%d"))

write.csv(covid_final, paste0("covid_nytimes_", format(Sys.time(), "%Y%m%d"), ".csv"), row.names = FALSE, na = "")

#drive_update(as_id("https://docs.google.com/spreadsheets/d/1l5YMJv8ZTEYc53n-cJuLYM4xDERLC-mEudNNQgbt-tM/edit#gid=182512028"), paste0("covid_nytimes_", format(Sys.time(), "%Y%m%d"), ".csv"))

ss <- as_sheets_id("https://docs.google.com/spreadsheets/d/1l5YMJv8ZTEYc53n-cJuLYM4xDERLC-mEudNNQgbt-tM/edit#gid=182512028")

sheet_write(covid_final, ss = ss, sheet = "Sheet1")

1

#The number "1" above in this code is meant to automatically respond to the following prompt:
# The googlesheets4 package is requesting access to your Google account. Select a pre-authorised account or enter '0' to obtain a new token. Press Esc/Ctrl + C to abort.
# 1: andrewcberkley@gmail.com