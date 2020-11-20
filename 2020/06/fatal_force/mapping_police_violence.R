setwd("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/06/fatal_force/")

zipcode_coordinates <- read.csv("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/06/fatal_force/us-zip-code-latitude-and-longitude.csv", sep=",", stringsAsFactors=FALSE)
city_state_coordinates <- zipcode_coordinates[,c(2,3,4,5)]
rm(zipcode_coordinates)
city_state_coordinates$city_state <- paste(city_state_coordinates$City,"-",city_state_coordinates$State)
city_state_coordinates <- city_state_coordinates[,c(5,3,4)]

fatal_shootings_wapo <- read.csv("https://raw.githubusercontent.com/washingtonpost/data-police-shootings/master/fatal-police-shootings-data.csv", stringsAsFactors=FALSE)
fatal_shootings_wapo_clean <- fatal_shootings_wapo[,c(1,2,8,3,9,10)]
rm(fatal_shootings_wapo)
fatal_shootings_wapo_clean$race[fatal_shootings_wapo_clean$race == "A"] <- "Asian"
fatal_shootings_wapo_clean$race[fatal_shootings_wapo_clean$race == "B"] <- "Black"
fatal_shootings_wapo_clean$race[fatal_shootings_wapo_clean$race == "H"] <- "Hispanic"
fatal_shootings_wapo_clean$race[fatal_shootings_wapo_clean$race == "N"] <- "Native American"
fatal_shootings_wapo_clean$race[fatal_shootings_wapo_clean$race == "O"] <- "Other"
fatal_shootings_wapo_clean$race[fatal_shootings_wapo_clean$race == ""] <- "Unknown race"
fatal_shootings_wapo_clean$race[fatal_shootings_wapo_clean$race == "W"] <- "White"
fatal_shootings_wapo_clean$city_state <- paste(fatal_shootings_wapo_clean$city, "-", fatal_shootings_wapo_clean$state)
fatal_shootings_wapo_clean <- fatal_shootings_wapo_clean[,c(1,2,3,4,7)]
fatal_shootings_wapo_clean$latitude <- city_state_coordinates[match(fatal_shootings_wapo_clean$city_state, city_state_coordinates$city_state), 2]
fatal_shootings_wapo_clean$longitude <- city_state_coordinates[match(fatal_shootings_wapo_clean$city_state, city_state_coordinates$city_state), 3]

police_killings <- read.csv("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/06/fatal_force/police_killings_2013-2019.csv", stringsAsFactors=FALSE)
police_killings_clean <- police_killings[,c(24,1,4,6,8,9)]
rm(police_killings)
colnames(police_killings_clean) <- c("id", "name", "race", "date", "city", "state")
police_killings_clean <- police_killings_clean[order(police_killings_clean$id),]
rownames(police_killings_clean) <- NULL
police_killings_clean$city_state <- paste(police_killings_clean$city, "-", police_killings_clean$state)
police_killings_clean <- police_killings_clean[,c(1,2,3,4,7)]
police_killings_clean$latitude <- city_state_coordinates[match(police_killings_clean$city_state, city_state_coordinates$city_state), 2]
police_killings_clean$longitude <- city_state_coordinates[match(police_killings_clean$city_state, city_state_coordinates$city_state), 3]

full_fatal_force <- rbind(police_killings_clean, fatal_shootings_wapo_clean)
full_fatal_force_deduped <- unique(full_fatal_force)
rm(full_fatal_force)

full_fatal_force_deduped$date <- as.Date(full_fatal_force_deduped$date)
full_fatal_force_deduped$latitude <- as.numeric(full_fatal_force_deduped$latitude)
full_fatal_force_deduped$longitude <- as.numeric(full_fatal_force_deduped$longitude)

fatal_prime <- full_fatal_force_deduped[!is.na(full_fatal_force_deduped$id),]
fatal_na <- full_fatal_force_deduped[is.na(full_fatal_force_deduped$id),]
full_fatal_force_beta <- full_fatal_force_deduped[!duplicated(full_fatal_force_deduped$id),]
full_fatal_force_final <- rbind(full_fatal_force_beta, fatal_na)

full_fatal_force_final <- full_fatal_force_final[!is.na(full_fatal_force_final$latitude), ]
full_fatal_force_final<- full_fatal_force_final[order(full_fatal_force_final$date),]
full_fatal_force_final$race <- tools::toTitleCase(full_fatal_force_final$race)

rm(fatal_prime)
rm(fatal_na)
rm(full_fatal_force_beta)
rm(full_fatal_force_deduped)

full_fatal_force_white <- full_fatal_force_final[full_fatal_force_final$race == 'White',]
full_fatal_force_black <- full_fatal_force_final[full_fatal_force_final$race == 'Black',]
full_fatal_force_asian_pacific_islander <- subset(full_fatal_force_final , race == 'Asian'|race == 'Pacific Islander')
full_fatal_force_hispanic <- full_fatal_force_final[full_fatal_force_final$race == 'Hispanic',]
full_fatal_force_native_americans <- full_fatal_force_final[full_fatal_force_final$race == 'Native American',]
full_fatal_force_unknown_other <- subset(full_fatal_force_final , race == 'Unknown Race'|race == 'Other')


write.csv(full_fatal_force_final, "full_fatal_force_final.csv", na = "", row.names = FALSE)

write.csv(full_fatal_force_white, "full_fatal_force_white.csv", na = "", row.names = FALSE)
write.csv(full_fatal_force_black, "full_fatal_force_black.csv", na = "", row.names = FALSE)
write.csv(full_fatal_force_asian_pacific_islander, "full_fatal_force_asian_pacific_islander.csv", na = "", row.names = FALSE)
write.csv(full_fatal_force_hispanic, "full_fatal_force_hispanic.csv", na = "", row.names = FALSE)
write.csv(full_fatal_force_native_americans, "full_fatal_force_native_americans.csv", na = "", row.names = FALSE)
write.csv(full_fatal_force_unknown_other, "full_fatal_force_unknown_other.csv", na = "", row.names = FALSE)

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
with open("full_fatal_force_final.csv") as f:
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
array.array('f', points).tofile(open('full_fatal_force_v1.bin', 'wb'))
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
with open("full_fatal_force_white.csv") as f:
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
array.array('f', points).tofile(open('full_fatal_force_white.bin', 'wb'))

#black
raw_data = []
with open("full_fatal_force_black.csv") as f:
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
array.array('f', points).tofile(open('full_fatal_force_black.bin', 'wb'))

#asian/pacific islander
raw_data = []
with open("full_fatal_force_asian_pacific_islander.csv") as f:
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
array.array('f', points).tofile(open('full_fatal_force_asian_pacific_islander.bin', 'wb'))

#hispanic
raw_data = []
with open("full_fatal_force_hispanic.csv") as f:
  reader = csv.DictReader(f, delimiter=",")
  for row in reader:
    raw_data.append(row)
len(raw_data)
raw_data[0]
points = []
for row in raw_data:
  x,y = LngLatToWebMercator([float(row['longitude']), float(row['latitude'])])
  packedColor = PackColor([255, 255, 0])
  epoch_0 = FormatDateStr(row['date'], '%Y-%m-%d')
  epoch_1 = epoch_0 + 60*60*24*28
  points += [x,y,packedColor,epoch_0,epoch_1]
array.array('f', points).tofile(open('full_fatal_force_hispanic.bin', 'wb'))

#native americans
raw_data = []
with open("full_fatal_force_native_americans.csv") as f:
  reader = csv.DictReader(f, delimiter=",")
  for row in reader:
    raw_data.append(row)
len(raw_data)
raw_data[0]
points = []
for row in raw_data:
  x,y = LngLatToWebMercator([float(row['longitude']), float(row['latitude'])])
  packedColor = PackColor([255, 153, 51])
  epoch_0 = FormatDateStr(row['date'], '%Y-%m-%d')
  epoch_1 = epoch_0 + 60*60*24*28
  points += [x,y,packedColor,epoch_0,epoch_1]
array.array('f', points).tofile(open('full_fatal_force_native_americans.bin', 'wb'))

#unknown other
raw_data = []
with open("full_fatal_force_unknown_other.csv") as f:
  reader = csv.DictReader(f, delimiter=",")
  for row in reader:
    raw_data.append(row)
len(raw_data)
raw_data[0]
points = []
for row in raw_data:
  x,y = LngLatToWebMercator([float(row['longitude']), float(row['latitude'])])
  packedColor = PackColor([255, 0, 255])
  epoch_0 = FormatDateStr(row['date'], '%Y-%m-%d')
  epoch_1 = epoch_0 + 60*60*24*28
  points += [x,y,packedColor,epoch_0,epoch_1]
array.array('f', points).tofile(open('full_fatal_force_unknown_other.bin', 'wb'))