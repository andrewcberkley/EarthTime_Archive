library(readxl)
library(dplyr)
sheet <- read_excel("~/ptm_evolution_2019_bubble_map.xlsx")
three_million_cities <- readRDS("~/three_million_cities.rds")
three_million_cities <- three_million_cities[order(-three_million_cities$Population),]
head(three_million_cities)
sheet$lat <- three_million_cities[match(sheet$AccentCity, three_million_cities$AccentCity), 3]
sheet$lon <- three_million_cities[match(sheet$AccentCity, three_million_cities$AccentCity), 4]
sheet <- sheet[,c(1,24,25,2:23)]
write.csv(sheet, "ptm_evolution2019.csv", na = "", row.names = FALSE, fileEncoding = "UTF-8")