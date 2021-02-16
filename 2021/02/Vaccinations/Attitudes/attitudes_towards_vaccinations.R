setwd(file.path(Sys.getenv('my_dir'),'2021/02/Vaccinations/attitudes/'))

library(tidyverse)
library(data.table)
library(reshape2)
library(dplyr)
library(zoo)
library(googledrive)
library(googlesheets4)
#library(plyr)

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
#Valid Values	1	1 - Strongly agree
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

data2$date <- stringr::str_extract(data2$date, ".{0,0}.{0,10}")
#data2$date <- gsub("-", "", data2$date)

wide <- data2 %>%
  group_by(date) %>%
  mutate(idx = row_number()) %>%
  spread(date, vac_1) %>%
  select(-idx)

