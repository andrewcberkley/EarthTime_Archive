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

owid_vaccinations$iso_code[owid_vaccinations$location == "England"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Northern Ireland"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Scotland"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Wales"] <- "GBR"
owid_vaccinations$iso_code[owid_vaccinations$location == "Northern Cyprus"] <- "CYP"
owid_vaccinations$iso_code[owid_vaccinations$location == "European Union"] <- "EU"

row.names.keep <- c("AFG", "ALB", "DZA", "AND", "AGO", "AIA", "ATG", "ARG", "ARM", "ABW", "AUS", "AUT", "AZE", "BHS", "BHR", "BGD", "BRB", "BLR", "BEL", "BLZ", "BEN", "BMU", "BTN", "BOL", "BES", "BIH", "BWA", "BRA", "VGB", "BRN", "BGR", "BFA", "MMR", "BDI", "CPV", "KHM", "CMR", "CAN", "CYM", "CAF", "TCD", "GBR", "CHL", "CHN", "COL", "COG", "COD", "CRI", "CIV", "HRV", "CUB", "CUW", "CYP", "CZE", "DNK", "DJI", "DMA", "DOM", "ECU", "EGY", "SLV", "GNQ", "ERI", "EST", "SWZ", "ETH", "FRO", "FJI", "FIN", "FRA", "GUF", "PYF", "GAB", "GMB", "GEO", "DEU", "GHA", "GIB", "GRC", "GRL", "GRD", "GLP", "GTM", "GIN", "GNB", "GUY", "HTI", "VAT", "HND", "HKG", "HUN", "ISL", "IND", "IDN", "IRN", "IRQ", "IRL", "IMN", "ISR", "ITA", "JAM", "JPN", "JOR", "KAZ", "KEN", "KOR", "XKS", "KWT", "KGZ", "LAO", "LVA", "LBN", "LBR", "LBY", "LIE", "LTU", "LUX", "MAC", "MDG", "MWI", "MYS", "MDV", "MLI", "MLT", "MTQ", "MRT", "MUS", "MYT", "MEX", "MDA", "MCO", "MNG", "MNE", "MSR", "MAR", "MOZ", "NAM", "NPL", "NLD", "NCL", "NZL", "NIC", "NER", "NGA", "MKD", "NOR", "OMN", "PAK", "PAN", "PNG", "PRY", "PER", "PHL", "POL", "PRT", "QAT", "REU", "ROU", "RUS", "RWA", "BLM", "KNA", "LCA", "SPM", "VCT", "SMR", "STP", "SAU", "SEN", "SRB", "SYC", "SLE", "SGP", "SXM", "SVK", "SVN", "SOM", "ZAF", "SSD", "ESP", "LKA", "MAF", "SDN", "SUR", "SWE", "CHE", "SYR", "TWN", "TZA", "THA", "TLS", "TGO", "TTO", "TUN", "TUR", "TCA", "UGA", "UKR", "ARE", "GBR", "URY", "USA", "UZB", "VEN", "VNM", "PSE", "YEM", "ZMB", "ZWE") #As of 13 September 2021, OWID added excess unidentifiable ISO codes causes a breaking point in the EarthTime chloropleth build, so keeping the countries we know that work

owid_vaccinations <- owid_vaccinations[owid_vaccinations$iso_code %in% row.names.keep, ]

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