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


