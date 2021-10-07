setwd(file.path(Sys.getenv('my_dir'),'2021/10/air_pollution_in_switzerland'))

pm25 <- read.csv("PM2.5.csv", header=FALSE)
pm25_clean <- data.frame(do.call('rbind', strsplit(as.character(pm25$V1),';',fixed=TRUE)))
pm25