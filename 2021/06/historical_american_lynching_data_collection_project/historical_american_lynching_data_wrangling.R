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

HAL_final <- HAL[,c(8,9,2,4)]

HAL_final_black <- HAL_final[HAL_final$Race == 'Black',]
write.csv(HAL_final_black, "HAL_final_black.csv", na = "", row.names = FALSE)
HAL_final_white <- HAL_final[HAL_final$Race == 'White',]
write.csv(HAL_final_white, "HAL_final_white.csv", na = "", row.names = FALSE)
HAL_final_other <- subset(HAL_final , Race == 'Unknown'|race == 'Other')
write.csv(HAL_final_white, "HAL_final_other.csv", na = "", row.names = FALSE)

library(reticulate)
use_python("C:/Program Files/Anaconda3/", required = TRUE)
#py_config()
#py_install("pandas")

repl_python()

import array, csv, math, os, time
from datetime import timedelta, date, datetime


def FormatDateStr(date_str, format_str):
  return time.mktime(time.strptime(date_str, format_str))

def LngLatToWebMercator(lnglat):
  (lng, lat) = lnglat
x = (lng + 180.0) * 256.0 / 360.0
y = 128.0 - math.log(math.tan((lat + 90.0) * math.pi / 360.0)) * 128.0 / math.pi
return [x, y]


def PackColor(color):
  return color[0] + color[1] * 256.0 + color[2] * 256.0 * 256.0;

raw_data = []
with open("full_fatal_force_final_14122020.csv") as f:
  reader = csv.DictReader(f, delimiter=",")
for row in reader:
  raw_data.append(row)

len(raw_data)

raw_data[0]


#format x,y,packed_color,epoch_0,epoch_1
points = []
for row in raw_data:
  x,y = LngLatToWebMercator([float(row['longitude']), float(row['latitude'])])
packedColor = PackColor([0.6, 0.4, 0.8])
epoch_0 = FormatDateStr(row['date'], '%Y-%m-%d')
epoch_1 = epoch_0 + 60*60*24*28
points += [x,y,packedColor,epoch_0,epoch_1]
array.array('f', points).tofile(open('full_fatal_force_v1_14122020.bin', 'wb'))
#If Python is throwing a "ValueError: could not convert string to float:" error, make sure that *all* NaNs are removed from "date", "latitude", and/or "longitude" columns

# #The below is for **SPECIFIC** races

#Which color for which ethnicity?
#https://blog.datawrapper.de/ethnicitycolors/

#WaPo map ’18 color scheme used below

# white = red {255, 0, 0}
# black = blue {0, 0, 255}
# asian/pacific islander = green {0, 255, 0}
# hispanic = yellow {255, 255, 0}
# native = orange {255, 153, 51}
# unknown/other = purple {255, 0, 255}

#white
raw_data = []
with open("full_fatal_force_white_14122020.csv") as f:
  reader = csv.DictReader(f, delimiter=",")
for row in reader:
  raw_data.append(row)
len(raw_data)
raw_data[0]
points = []
for row in raw_data:
  x,y = LngLatToWebMercator([float(row['longitude']), float(row['latitude'])])
packedColor = PackColor([255, 0, 0])
epoch_0 = FormatDateStr(row['date'], '%Y-%m-%d')
epoch_1 = epoch_0 + 60*60*24*28
points += [x,y,packedColor,epoch_0,epoch_1]
array.array('f', points).tofile(open('full_fatal_force_white_14122020.bin', 'wb'))

#black
raw_data = []
with open("full_fatal_force_black_14122020.csv") as f:
  reader = csv.DictReader(f, delimiter=",")
for row in reader:
  raw_data.append(row)
len(raw_data)
raw_data[0]
points = []
for row in raw_data:
  x,y = LngLatToWebMercator([float(row['longitude']), float(row['latitude'])])
packedColor = PackColor([0, 0, 255])
epoch_0 = FormatDateStr(row['date'], '%Y-%m-%d')
epoch_1 = epoch_0 + 60*60*24*28
points += [x,y,packedColor,epoch_0,epoch_1]
array.array('f', points).tofile(open('full_fatal_force_black_14122020.bin', 'wb'))

#asian/pacific islander
raw_data = []
with open("full_fatal_force_asian_pacific_islander_14122020.csv") as f:
  reader = csv.DictReader(f, delimiter=",")
for row in reader:
  raw_data.append(row)
len(raw_data)
raw_data[0]
points = []
for row in raw_data:
  x,y = LngLatToWebMercator([float(row['longitude']), float(row['latitude'])])
packedColor = PackColor([0, 255, 0])
epoch_0 = FormatDateStr(row['date'], '%Y-%m-%d')
epoch_1 = epoch_0 + 60*60*24*28
points += [x,y,packedColor,epoch_0,epoch_1]
array.array('f', points).tofile(open('full_fatal_force_asian_pacific_islander_14122020.bin', 'wb'))
