setwd(file.path(Sys.getenv('my_dir'),'2021/02/Vaccinations/attitudes/'))

library(tidyverse)
library(data.table)
library(reshape2)
library(dplyr)
library(zoo)
library(googledrive)
library(googlesheets4)
#library(plyr)
library(lubridate)

# download a .zip file of the repository
# from the "Clone or download - Download ZIP" button
# on the GitHub repository of interest
download.file(url = "https://github.com/YouGov-Data/covid-19-tracker/archive/master.zip"
              , destfile = "YouGov-Data-covid-19-tracker.zip")

# unzip the .zip file
unzip(zipfile = "YouGov-Data-covid-19-tracker.zip")

# get all the zip files
zipF <- list.files(path = file.path(Sys.getenv('my_dir'),'2021/02/Vaccinations/attitudes/covid-19-tracker-master/data/'), pattern = "*.zip", full.names = TRUE)

# unzip all your files
plyr::ldply(.data = zipF, .fun = unzip, exdir = file.path(Sys.getenv('my_dir'),'2021/02/Vaccinations/attitudes/covid-19-tracker-master/data/'))

# set the working directory
# to be inside the newly unzipped 
# GitHub repository of interest
setwd(file.path(Sys.getenv('my_dir'),'2021/02/Vaccinations/attitudes/covid-19-tracker-master/data/'))
# examine the contents
list.files()

temp = list.files(pattern="*.csv")
for (i in 1:length(temp)) assign(temp[i], read.csv(temp[i]))

rm(i)
rm(temp)
rm(zipF)

#vac_1		
#Value
#Standard Attributes	Label	If a Covid-19 vaccine were made available to me this week, I would definitely get it:
#  Type	Numeric
#Measurement	Nominal
#Valid Values	
#1	1 - Strongly agree
#2	2
#3	3
#4	4
#5	5 - Strongly disagree


#https://stackoverflow.com/questions/45670564/calling-a-data-frame-from-global-env-and-adding-a-column-with-the-data-frame-nam
l_df <- Filter(function(x) is(x, "data.frame"), mget(ls()))



#https://www.edureka.co/community/1310/how-to-convert-list-dataframes-in-to-single-dataframe-using
data <- plyr::ldply(l_df, data.frame)
data2 <- data[,c(".id","ï..RecordNo","endtime","vac_1")]


rm(list=setdiff(ls(), c("l_df","data", "data2")))
#rm(list=setdiff(ls(), "data2"))

colnames(data2) <- c("country", "record_number", "date", "vac_1")

data2$country <- gsub(".csv", "", data2$country)

data2$vac_1 <- gsub("1 - Strongly agree", "1", data2$vac_1)
data2$vac_1 <- gsub("5 â€“ Strongly disagree", "5", data2$vac_1)
#data2$vac_1 <- as.numeric(data2$vac_1)
data2$vac_1 <- gsub("1", "Strongly agree", data2$vac_1)
data2$vac_1 <- gsub("2", "Agree", data2$vac_1)
data2$vac_1 <- gsub("3", "Neutral", data2$vac_1)
data2$vac_1 <- gsub("4", "Disagree", data2$vac_1)
data2$vac_1 <- gsub("5", "Strongly disagree", data2$vac_1)

data2$date <- stringr::str_extract(data2$date, ".{0,0}.{0,10}")

data2 <- data2[,-2] #removal of 'record_number'

data2point1 <- data2 %>%
  group_by(country, date, vac_1) %>%
  mutate(response_count = n())

data2point2 <- data2point1 %>%
  group_by(country, date) %>%
  mutate(response_total = n())

#Filter "Strongly agree" or "Agree"
sub_data2 <- data2point2[data2point2$vac_1 %in% c("Strongly agree", "Agree") ,]
deduped_data <- unique( sub_data2[ , 1:5 ] )

data3 <- deduped_data %>% group_by(country, date, response_total) %>%
  summarize(attitude_sum = sum(response_count))


data3$response_attiude <- (data3$attitude_sum/data3$response_total)*100

#Calculating mean values based on two different groupings in a data frame [duplicate]
#https://stackoverflow.com/questions/23553407/calculating-mean-values-based-on-two-different-groupings-in-a-data-frame
#data3 <- aggregate(x=data2$vac_1,
#                   by=list(data2$country,data2$date),
#                   FUN=mean)

data3$response_attiude <- format(round(data3$response_attiude, 2), nsmall = 2)
data3 <- data3[,c("country", "date", "response_attiude")]
colnames(data3) <- c("name", "date", "value")

#Today - Need a dummy date to fill over wide dataframe up to present day
data3[nrow(data3) + 1,] <- list(name = "NA", date = format(Sys.time(), "%d/%m/%Y"), value = "0")


data3$date <- as.Date(parse_date_time(data3$date, c('dmy', 'ymd_hms')))

data3 <- data3[complete.cases(data3), ]

#How to add only missing Dates in Dataframe
#https://stackoverflow.com/questions/50192024/how-to-add-only-missing-dates-in-dataframe
data4<-merge(data.frame(date= as.Date(min(data3$date):max(data3$date),"1970-1-1")),
             data3, by = "date", all = TRUE)
data4$date <- gsub("-", "", data4$date)

decent_df <- data4 %>%
  group_by(name) %>%
  mutate(idx = row_number()) %>%
  spread(date, value) %>%
  select(-idx)

collapsed_df <- setDT(decent_df)[, lapply(.SD, function(x)
  {x <- unique(x[!is.na(x)])
  if(length(x) == 1) as.character(x)
  else if(length(x) == 0) NA_character_
  else "multiple"}),
  by=name]

wide_minus <- collapsed_df[,-c(1)]
wide_filled_over <- t(apply(wide_minus, 1, function(x) na.locf(x, fromLast = F, na.rm = F)))
wide_plus <- collapsed_df[,c(1)]
wide_final <- cbind(wide_plus, wide_filled_over)

colnames(wide_final)[1] <- "iso3"

wide_final$iso3[wide_final$iso3 == "australia"] <- "AUS"
wide_final$iso3[wide_final$iso3 == "canada"] <- "CAN"
wide_final$iso3[wide_final$iso3 == "finland"] <- "FIN"
wide_final$iso3[wide_final$iso3 == "france"] <- "FRA"
wide_final$iso3[wide_final$iso3 == "germany"] <- "DEU"
wide_final$iso3[wide_final$iso3 == "italy"] <- "ITA"
wide_final$iso3[wide_final$iso3 == "japan"] <- "JPN"
wide_final$iso3[wide_final$iso3 == "netherlands"] <- "NLD"
wide_final$iso3[wide_final$iso3 == "norway"] <- "NOR"
wide_final$iso3[wide_final$iso3 == "singapore"] <- "SGP"
wide_final$iso3[wide_final$iso3 == "south-korea"] <- "KOR"
wide_final$iso3[wide_final$iso3 == "spain"] <- "ESP"
wide_final$iso3[wide_final$iso3 == "sweden"] <- "SWE"
wide_final$iso3[wide_final$iso3 == "united-kingdom"] <- "GBR"

final_df <- wide_final[complete.cases(wide_final), ]

setwd(file.path(Sys.getenv('my_dir'),'2021/02/Vaccinations/attitudes/'))

write.csv(final_df, paste0("vaccination_attitudes", format(Sys.time(), "%Y%m%d"), ".csv"), row.names = FALSE, na = "")