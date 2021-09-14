#Tracking COVID-19 vaccination rates is crucial to understand the scale of protection against the virus, and how this is distributed across the global population.

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

owid_vaccinations <- owid_vaccinations[!grepl("OWID_", owid_vaccinations$iso_code),]

row.names.keep <- c("AFG", "AGO", "AIA", "ALB", "AND", "ARE", "ARG", "ATG", "AUS", "AUT", "AZE", "BEL", "BGD", "BGR", "BHR", "BHS", "BLR", "BLZ", "BMU", "BOL", "BRA", "BRB", "BRN", "BTN", "CAN", "CHE", "CHL", "CHN", "CIV", "COL", "CPV", "CRI", "CYM", "CYP", "CZE", "DEU", "DMA", "DNK", "DOM", "DZA", "ECU", "EGY", "ESP", "EST", "EU", "FIN", "FLK", "FRA", "FRO", "GAB", "GBR", "GEO", "GGY", "GHA", "GIB", "GIN", "GMB", "GNQ", "GRC", "GRD", "GRL", "GTM", "GUY", "HKG", "HND", "HRV", "HUN", "IDN", "IMN", "IND", "IRL", "IRN", "IRQ", "ISL", "ISR", "ITA", "JAM", "JEY", "JOR", "JPN", "KAZ", "KEN", "KHM", "KNA", "KOR", "KWT", "LAO", "LBN", "LCA", "LIE", "LKA", "LTU", "LUX", "LVA", "MAC", "MAR", "MCO", "MDA", "MDV", "MEX", "MKD", "MLI", "MLT", "MMR", "MNE", "MNG", "MOZ", "MRT", "MSR", "MUS","MWI", "MYS", "NAM", "NGA", "NLD", "NOR", "NPL", "NZL", "OMN", "PAK", "PAN", "PER", "PHL", "POL", "PRT", "PRY", "PSE", "QAT", "ROU", "RUS", "RWA", "SAU", "SEN", "SGP", "SHN", "SLE", "SLV", "SMR", "SRB", "STP", "SUR", "SVK", "SVN", "SWE", "SYC", "TCA", "TGO", "THA", "TTO", "TUN", "TUR", "TWN", "UGA", "UKR", "URY", "USA", "VCT", "VEN", "VNM", "ZAF", "ZWE")

owid_vaccinations$iso_code[owid_vaccinations$location == "England"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Northern Ireland"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Scotland"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Wales"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Northern Cyprus"] <- "CYP"
owid_vaccinations$iso_code[owid_vaccinations$location == "European Union"] <- "EU"

total_vaccinations_per_100 <- owid_vaccinations[,c(2,3,10)]
daily_vaccinations_per_million <- owid_vaccinations[,c(2,3,14)]
full_vaccination_percentage <- owid_vaccinations[,c(2,3,12)]

owid_list <- list()

owid_list[[1]] <- total_vaccinations_per_100 %>% 
  group_by(date) %>% 
  mutate(idx = row_number()) %>% 
  spread(date, total_vaccinations_per_hundred) %>% 
  select(-idx)

owid_list[[2]]  <- daily_vaccinations_per_million %>% 
  group_by(date) %>% 
  mutate(idx = row_number()) %>% 
  spread(date, daily_vaccinations_per_million) %>% 
  select(-idx)

owid_list[[3]]  <- full_vaccination_percentage %>% 
  group_by(date) %>% 
  mutate(idx = row_number()) %>% 
  spread(date, people_fully_vaccinated_per_hundred) %>% 
  select(-idx)

rm(total_vaccinations_per_100)
rm(daily_vaccinations_per_million)
rm(full_vaccination_percentage)

rm(owid_vaccinations)

create_df <- function (i) {
    i <- setDT(i)[, lapply(.SD, mean, na.rm=TRUE), by=iso_code]
    
    colnames(i) <- gsub("-", "", colnames(i))
    
    i[i=="NaN"] <- NA
    i[i==0] <- NA
    
    x <- i[,-c(1)]
    y <- t(apply(x, 1, function(x) na.locf(x, fromLast = F, na.rm = F)))
    z <- i[,c(1)]
    #assign(paste0("DF", i), as.data.frame(cbind(z, y)), envir = .GlobalEnv)
    cbind(z, y)
}

owid_list <- lapply(owid_list, function(y) create_df(y))

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

total_vaccinations_per_100 <- as.data.frame(owid_list[1])
daily_vaccinations_per_million <- as.data.frame(owid_list[2])
full_vaccination_percentage <- as.data.frame(owid_list[3])

rm(owid_list)

destroyX(total_vaccinations_per_100)
destroyX(daily_vaccinations_per_million)
destroyX(full_vaccination_percentage)

rm(create_df)
rm(destroyX)

files <- mget(ls())

for (i in 1:length(files)){
  write.csv(files[[i]], paste(names(files[i]), "- ",format(Sys.time(), "%Y%m%d"), ".csv"), row.names = FALSE, na = "")
}

#Data Citations:
#Hasell, J., Mathieu, E., Beltekian, D. et al. A cross-country database of COVID-19 testing. Sci Data 7, 345 (2020). https://doi.org/10.1038/s41597-020-00688-8
#Jones, Sarah P., Imperial College London Big Data Analytical Unit and YouGov Plc. 2020, Imperial College London YouGov Covid Data Hub, v1.0, YouGov Plc, April 2020

ss_per_100 <- as_sheets_id("https://docs.google.com/spreadsheets/d/1a_GBckfFUWN209D7wiXVUvtSy44-wXIE7BjbHB7lv3E/edit#gid=1175349253")
ss_per_million <- as_sheets_id("https://docs.google.com/spreadsheets/d/1PMlicFyjtEA9yCY7YhkqDgQbuOAp5_KTZW23fdjof0Q/edit#gid=1358095190")
ss_full_percent <- as_sheets_id("https://docs.google.com/spreadsheets/d/1GYZTUpUhkcnXRBj9IwLqGzxL6Mq_Ne-Qejyk_JAqCgc/edit#gid=1336920075")

sheet_write(total_vaccinations_per_100, ss = ss_per_100, sheet = "Sheet1")

1

#The number "1" above in this code is meant to automatically respond to the following prompt:
# The googlesheets4 package is requesting access to your Google account. Select a pre-authorised account or enter '0' to obtain a new token. Press Esc/Ctrl + C to abort.
# 1: andrewcberkley@gmail.com

sheet_write(daily_vaccinations_per_million, ss = ss_per_million, sheet = "Sheet1")

1

sheet_write(full_vaccination_percentage, ss = ss_full_percent, sheet = "Sheet1")

1

rm(list = ls())
#.rs.restartR()