setwd(file.path(Sys.getenv('my_dir'),'2021/10/air_pollution_in_switzerland'))

df1 <- read.csv("PM2.5.csv", header=FALSE)
df2 <- data.frame(do.call('rbind', strsplit(as.character(df1$V1),';',fixed=TRUE)))
df3 <- df2[-c(1:6),]
colnames(df3) <- c("Date","Bern-Bollwerk","Lausanne-César-Roux","Lugano-Università","Zürich-Kaserne","Basel-Binningen","Dübendorf-Empa","Härkingen-A1","Sion-Aéroport-A9","Magadino-Cadenazzo","Payerne","Tänikon","Beromünster","Rigi-Seebodenalp","Jungfraujoch")

#How to replace with NA all values that are longer than 4 digits in R?
#https://stackoverflow.com/questions/62969140/how-to-replace-with-na-all-values-that-are-longer-than-4-digits-in-r
i = which(nchar(df3$Jungfraujoch) > 3) # indices of rows with digit length > 3
df3$Jungfraujoch[i] = NA