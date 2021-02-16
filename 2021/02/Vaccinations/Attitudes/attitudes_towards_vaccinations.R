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

#https://stackoverflow.com/questions/24195109/extract-columns-with-same-names-from-multiple-data-frames-r
test <- lapply(l_df, function(x) x$vac_1)




#Conditionally remove data frames from environment
#https://stackoverflow.com/questions/28195504/conditionally-remove-data-frames-from-environment
to.rm <- unlist(eapply(.GlobalEnv, function(x) is.data.frame(x) && ncol(x) < 3))
rm(list = names(to.rm)[to.rm], envir = .GlobalEnv)



#https://stackoverflow.com/questions/36923182/r-remove-a-row-from-all-data-frames-in-global-environment
dfs = sapply(ls(), is.data.frame) 
#https://stackoverflow.com/questions/62274164/remove-same-column-from-multiple-dataframes-in-r
dfs <- lapply(dfs, function(x) x[names(x) != "vac_1"])