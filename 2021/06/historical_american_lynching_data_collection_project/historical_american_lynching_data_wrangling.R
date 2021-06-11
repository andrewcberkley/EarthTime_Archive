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
rm(df)

as.data.frame(table(HAL$Race))
as.data.frame(table(HAL$State))
as.data.frame(table(HAL$Sex))

