setwd(file.path(Sys.getenv('my_dir'),'2021/10/air_pollution_in_switzerland'))

library(reshape2)
library(data.table)
library(dplyr)

df1 <- read.csv("PM2.5.csv", header=FALSE)
df2 <- data.frame(do.call('rbind', strsplit(as.character(df1$V1),';',fixed=TRUE)))
df3 <- df2[-c(1:6,555),]
colnames(df3) <- c("Date","Bern-Bollwerk","Lausanne-César-Roux","Lugano-Università","Zürich-Kaserne","Basel-Binningen","Dübendorf-Empa","Härkingen-A1","Sion-Aéroport-A9","Magadino-Cadenazzo","Payerne","Tänikon","Beromünster","Rigi-Seebodenalp","Jungfraujoch")

#How to replace with NA all values that are longer than 4 digits in R?
#https://stackoverflow.com/questions/62969140/how-to-replace-with-na-all-values-that-are-longer-than-4-digits-in-r
i = which(nchar(df3$Jungfraujoch) > 3) # indices of rows with digit length > 3
df3$Jungfraujoch[i] = NA

long_df <- reshape2::melt(df3, id.vars = "Date")
colnames(long_df) <- c("Date", "Station", "Value")
long_df$Date <- gsub("\\.", "/", long_df$Date)
#long_df$Date <- format(as.Date(long_df$Date), "%d/%m/%y")

station_location <- data.table(name = c("Bern-Bollwerk","Lausanne-César-Roux","Lugano-Università","Zürich-Kaserne","Basel-Binningen","Dübendorf-Empa","Härkingen-A1","Sion-Aéroport-A9","Magadino-Cadenazzo","Payerne","Tänikon","Beromünster","Rigi-Seebodenalp","Jungfraujoch"), stationLat = c(46.948, 46.5197, 46.0037, 47.3769, 47.5596, 47.3971, 47.3073, 46.2227, 46.1464, 46.822, 47.4796, 47.2064, 47.056, 46.5483), stationLong = c(7.4474, 6.6323, 8.9511, 8.5417, 7.5886, 8.618, 7.819, 7.3379, 8.8519, 6.9406, 8.9053, 8.1916, 8.4852, 7.9806))

long_df$Lat <- NA
long_df$Long <- NA

long_df <- as.data.frame(long_df)
station_location <- as.data.frame(station_location)

long_df[,"Lat"] <- station_location[match(long_df[,"Station"], station_location[,"name"]), "stationLat"]
long_df[,"Long"] <- station_location[match(long_df[,"Station"], station_location[,"name"]), "stationLong"]

rm(list=setdiff(ls(), "long_df"))

#WHO Air Quality Values of PM2.5 Concentration (μg/m3) according to the Swiss Tropical and Public Health Institute
good <- long_df %>% filter( between(Value, 0, 10) ) #Green
moderate <- long_df %>% filter( between(Value, 11, 15) ) #Yellow
unhealthy_for_sensiitve_groups <- long_df %>% filter( between(Value, 16, 25) ) #Orange
unhealthy <- long_df %>% filter( between(Value, 26, 35) ) #Red
very_unhealthy <- long_df %>% filter( between(Value, 36, 40) ) #Purple
hazardous <- long_df %>% filter( between(Value, 41, 500) ) #Maroon/Burgundy

rm(long_df)

