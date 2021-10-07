setwd(file.path(Sys.getenv('my_dir'),'2021/10/air_pollution_in_switzerland'))

library(reshape2)
library(data.table)

df1 <- read.csv("PM2.5.csv", header=FALSE)
df2 <- data.frame(do.call('rbind', strsplit(as.character(df1$V1),';',fixed=TRUE)))
df3 <- df2[-c(1:6,555),]
colnames(df3) <- c("Date","Bern-Bollwerk","Lausanne-César-Roux","Lugano-Università","Zürich-Kaserne","Basel-Binningen","Dübendorf-Empa","Härkingen-A1","Sion-Aéroport-A9","Magadino-Cadenazzo","Payerne","Tänikon","Beromünster","Rigi-Seebodenalp","Jungfraujoch")

#How to replace with NA all values that are longer than 4 digits in R?
#https://stackoverflow.com/questions/62969140/how-to-replace-with-na-all-values-that-are-longer-than-4-digits-in-r
i = which(nchar(df3$Jungfraujoch) > 3) # indices of rows with digit length > 3
df3$Jungfraujoch[i] = NA

long_df <- melt(df3, id.vars = "Date")
colnames(long_df) <- c("Date", "Station", "Value")
long_df$Date <- gsub("\\.", "/", long_df$Date)
#long_df$Date <- format(as.Date(long_df$Date), "%d/%m/%y")

station_location <- data.table(name = c("Bern-Bollwerk","Lausanne-César-Roux","Lugano-Università","Zürich-Kaserne","Basel-Binningen","Dübendorf-Empa","Härkingen-A1","Sion-Aéroport-A9","Magadino-Cadenazzo","Payerne","Tänikon","Beromünster","Rigi-Seebodenalp","Jungfraujoch"), stationLat = c(46.948, 46.5197, 46.0037, 47.3769, 47.5596, 47.3971, 47.3073, 46.2227, 46.1464, 46.822, 47.4796, 47.2064, 47.056, 46.5483), stationLong = c(7.4474, 6.6323, 8.9511, 8.5417, 7.5886, 8.618, 7.819, 7.3379, 8.8519, 6.9406, 8.9053, 8.1916, 8.4852, 7.9806))


long_df$Station[long_df$StationLat=="Bern-Bollwerk"] <- 46.948
long_df$StationLat[long_df$StationLat=="Lausanne-César-Roux"] <- 46.5197
long_df$StationLat[long_df$StationLat=="Lugano-Università"] <- 46.0037
long_df$StationLat[long_df$StationLat=="Zürich-Kaserne"] <- 47.3769
long_df$StationLat[long_df$StationLat=="Basel-Binningen"] <- 47.5596
long_df$StationLat[long_df$StationLat=="Dübendorf-Empa"] <- 47.3971
long_df$StationLat[long_df$StationLat=="Härkingen-A1"] <- 47.3073
long_df$StationLat[long_df$StationLat=="Sion-Aéroport-A9"] <- 46.2227
long_df$StationLat[long_df$StationLat=="Magadino-Cadenazzo"] <- 46.1464
long_df$StationLat[long_df$StationLat=="Payerne"] <- 46.822
long_df$StationLat[long_df$StationLat=="Tänikon"] <- 47.4796
long_df$StationLat[long_df$StationLat=="Beromünster"] <- 47.2064
long_df$StationLat[long_df$StationLat=="Rigi-Seebodenalp"] <- 47.056
long_df$StationLat[long_df$StationLat=="Jungfraujoch"] <- 46.5483

long_df$StationLong[long_df$StationLong=="Bern-Bollwerk"] <- 7.4474
long_df$StationLong[long_df$StationLong=="Lausanne-César-Roux"] <- 6.6323
long_df$StationLong[long_df$StationLong=="Lugano-Università"] <- 8.9511
long_df$StationLong[long_df$StationLong=="Zürich-Kaserne"] <- 8.5417
long_df$StationLong[long_df$StationLong=="Basel-Binningen"] <- 7.5886
long_df$StationLong[long_df$StationLong=="Dübendorf-Empa"] <- 8.618
long_df$StationLong[long_df$StationLong=="Härkingen-A1"] <- 7.819
long_df$StationLong[long_df$StationLong=="Sion-Aéroport-A9"] <- 7.3379
long_df$StationLong[long_df$StationLong=="Magadino-Cadenazzo"] <- 8.8519
long_df$StationLong[long_df$StationLong=="Payerne"] <- 6.9406
long_df$StationLong[long_df$StationLong=="Tänikon"] <- 8.9053
long_df$StationLong[long_df$StationLong=="Beromünster"] <- 8.1916
long_df$StationLong[long_df$StationLong=="Rigi-Seebodenalp"] <- 8.4852
long_df$StationLong[long_df$StationLong=="Jungfraujoch"] <- 7.9806