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
#HAL$Mo <- sprintf("%02d", as.numeric(HAL$Mo)) #Full Date
#HAL$Day <- sprintf("%02d", as.numeric(HAL$Day)) #Full Date
#HAL$Date <- paste0(HAL$Year,"-",HAL$Mo,"-",HAL$Day) #Full Date
rm(df)

as.data.frame(table(HAL$Race))
as.data.frame(table(HAL$State))
as.data.frame(table(HAL$County))
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

HAL_final <- HAL[,c(8,9,2,4)]
#HAL_final <- HAL[,c(11,12,9,6)] #Full Date

HAL_final_black <- HAL_final[HAL_final$Race == 'Black',]
write.csv(HAL_final_black, "HAL_final_black.csv", na = "", row.names = FALSE)
HAL_final_white <- HAL_final[HAL_final$Race == 'White',]
write.csv(HAL_final_white, "HAL_final_white.csv", na = "", row.names = FALSE)
HAL_final_other <- subset(HAL_final , Race == 'Unknown'|Race == 'Other')
write.csv(HAL_final_other, "HAL_final_other.csv", na = "", row.names = FALSE)

library(reticulate)
use_python("C:/ProgramData/Anaconda3/", required = TRUE)
#py_config()
#py_install("pandas")

source_python('aberk_support_functions_for_HAL_dotmap.py')