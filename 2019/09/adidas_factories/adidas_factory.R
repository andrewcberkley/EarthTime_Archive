adidas <- read.csv("C:/Users/ABERK/Desktop/adidas_primary_suppliers_and_subcontractors_2017-2019.csv", stringsAsFactors=FALSE)
View(adidas)
adidas <- read.csv("C:/Users/ABERK/Desktop/adidas_primary_suppliers_and_subcontractors_2017-2019.csv", stringsAsFactors=FALSE)
View(adidas)
three_million_cities <- readRDS("~/three_million_cities.rds")
three_million_cities <- readRDS("~/three_million_cities.rds")
View(three_million_cities)
colnames(three_million_cities)[,2] <- c("City")
colnames(three_million_cities) <- c("CityNormal", "City", "Latitude", "Longitude", "iso2", "iso3", "Region", "Population")
three_million_cities <- three_million_cities[order(-three_million_cities$Population),]
sheet <- adidas[,c(1,2,3,7,10:12)]
View(sheet)
sheet$lat <- NULL
sheet$long <- NULL
sheet <- sheet$lat
sheet <- adidas[,c(1,2,3,7,10:12)]
sheet$lat <- NA
sheet$long <- NA
sheet$lat <- three_million_cities[match(sheet$City, three_million_cities$City), 3]
sheet$long <- three_million_cities[match(sheet$City, three_million_cities$City), 4]
library(tidyverse)
sheet2 <- sheet %>%
group_by(Location, Account.Name, City, Tier, Product.Categories,lat, long) %>%
mutate(idx - row_number()) %>%
spread(year, Workers.Count) %>%
select(-idx)
sheet2 <- sheet %>%
group_by(Location, Account.Name, City, Tier, Product.Categories,lat, long) %>%
mutate(idx = row_number()) %>%
spread(year, Workers.Count) %>%
select(-idx)
sheet2 <- sheet %>%
group_by(Location, Account.Name, City, Tier, Product.Categories,lat, long) %>%
mutate(idx = row_number()) %>%
spread(Year, Workers.Count) %>%
select(-idx)
View(sheet2)
sheet2 <- sheet %>%
group_by(Location, Account.Name, City, Tier, Product.Categories) %>%
mutate(idx = row_number()) %>%
spread(Year, Workers.Count) %>%
select(-idx)
View(sheet2)
sheet2 <- sheet %>%
group_by(Account.Name) %>%
mutate(idx = row_number()) %>%
spread(Year, Workers.Count) %>%
select(-idx)
View(sheet2)
sheet3 <- setDT(sheet2)[, lapply(.SD, function(x)
{x <- unique(x[!is.na(x)])
if(length(x) == 1) as.character(x)
else if(length(x) == 0) NA_character_
else "multiple"}),
by=Account.Name]
library(data.table)
sheet3 <- setDT(sheet2)[, lapply(.SD, function(x)
{x <- unique(x[!is.na(x)])
if(length(x) == 1) as.character(x)
else if(length(x) == 0) NA_character_
else "multiple"}),
by=Account.Name]
View(sheet3)