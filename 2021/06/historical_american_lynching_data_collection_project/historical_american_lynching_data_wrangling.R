setwd(file.path(Sys.getenv('my_dir'),'2021/06/historical_american_lynching_data_collection_project'))

df <- readxl::read_xls("HAL.XLS")
us_county_centroids <- read.csv("us_county_centroids.csv")
us_county_centroids <- us_county_centroids[,c(2:5)]

df$Sex[df$Sex == "Fe"] <-  "Female"
df$Sex[df$Sex == "Unk"] <-  "Unknown"
df$Race[df$Race == "Blk"] <-  "Black"
df$Race[df$Race == "Wht"] <-  "White"
df$Race[df$Race == "Unk"] <-  "Unknown"
HAL <- df[,c(1,2,6,7,8,10)]
HAL <- HAL[!grepl("Indeterminant", HAL$County),]
HAL <- HAL[!grepl("Undetermined", HAL$County),]
rm(df)

as.data.frame(table(HAL$Race))
as.data.frame(table(HAL$State))
as.data.frame(table(HAL$Sex))
as.data.frame(table(HAL$Year))

HAL$Coordinates <- paste0(HAL$County,"-",HAL$State)
HAL$Latitude <- NA
HAL$Longitude <- NA
us_county_centroids$Coordinates <- paste0(us_county_centroids$county,"-",us_county_centroids$state)
us_county_centroids$Coordinates <- gsub(" County", "", us_county_centroids$Coordinates)
us_county_centroids$Coordinates <- gsub(" Parish", "", us_county_centroids$Coordinates)

HAL$Latitude <- us_county_centroids[match(HAL$Coordinates, us_county_centroids$Coordinates), 4]
HAL$Longitude <- us_county_centroids[match(HAL$Coordinates, us_county_centroids$Coordinates), 3]
rm(us_county_centroids)

