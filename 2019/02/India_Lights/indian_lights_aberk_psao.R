setwd(file.path(Sys.getenv('my_dir'),'2019/02/india_lights/'))

library(data.table)
library(indialights)

`indian_village_list+coordinates_clean` <- read.csv("~/indian_village_list+coordinates_clean.csv", header=FALSE, stringsAsFactors=FALSE)

df <- `indian_village_list+coordinates_clean`[-c(1),]

village_code_list <- as.list(df$V3)

LightsList <- list()

system.time(for (i in village_code_list[1:2500]) {
  cat("village_ids = ", as.character(i), "\n")
  Sys.sleep(1.0)
  VillageLights <- ial_villages(
    village_ids = i,
    interval_start = "1993.1",
    interval_stop = "2012.12"
  )
  LightsList[[i]] <- VillageLights
})

big_data_bigger_lights = rbindlist(LightsList)