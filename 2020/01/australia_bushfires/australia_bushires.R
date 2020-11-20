setwd("C:/Users/ABERK/Box/Data_Science_Exploration/ABERK/ABERK_Archive/EarthTime_Archive/2020/01/australia_bushfires/")

# library(tidyverse)
# library(zoo)

# fires_viirs <- read.csv("C:/Users/ABERK/Box/Data_Science_Exploration/ABERK/ABERK_Archive/EarthTime_Archive/2020/01/australia_bushfires/fire_nrt_V1_94463.csv", stringsAsFactors=FALSE)

# fires_viirs$acq_date <- gsub("-", "", fires_viirs$acq_date)
# fires_viirs_v2 <- fires_viirs[,c(1:3,6)]

# fires_transformed <- fires_viirs_v2 %>%
#     group_by(acq_date) %>%
#     mutate(idx = row_number()) %>%
#     spread(acq_date, bright_ti4) %>%
#     select(-idx)

# #fires_transformed_viirs[is.na(fires_transformed_viirs)] <- 0

# write.csv(fires_transformed_modis, "australia_bushfires_viirs.csv", na = "", row.names = FALSE)

# fires_modis <- read.csv("C:/Users/ABERK/Box/Data_Science_Exploration/ABERK/ABERK_Archive/EarthTime_Archive/2020/01/australia_bushfires/fire_nrt_M6_94462.csv", stringsAsFactors=FALSE)

# fires_modis$acq_date <- gsub("-", "", fires_modis$acq_date)
# fires_modis_v2 <- fires_modis[,c(1:3,6)]

# fires_transformed_modis <- fires_modis_v2 %>%
#     group_by(acq_date) %>%
#     mutate(idx = row_number()) %>%
#     spread(acq_date, brightness) %>%
#     select(-idx)

#fires_transformed_modis[is.na(fires_transformed_modis)] <- 0

# fires_transformed_modis$coordinates <- paste(fires_transformed_modis$latitude, fires_transformed_modis$longitude, sep = ",")

# fires_transformed_modis_v2 <- fires_transformed_modis[,c(96,3:95)]
# fires_transformed_modis_v3 <- cbind(coordinates = rownames(fires_modis_v2), fires_transformed_modis_v2)

# fires_transformed_modis_minus_df <- fires_transformed_modis[,-c(1:2)]
# fires_transformed_modis <- fires_transformed_modis[,-c(96)]
# fires_transformed_modis_minus_df <- fires_transformed_modis[,-c(1:2)]
# fires_transformed_modis_filled <- t(apply(fires_transformed_modis_minus_df, 1, function(x) na.locf(x, fromLast = F, na.rm = F)))
# fires_transformed_modis_lus_df<- fires_transformed_modis[,c(1:2)]
# final_fires_modis <- cbind(fires_transformed_modis_lus_df, fires_transformed_modis_filled)

#write.csv(fires_transformed_modis, "australia_bushfires_modis.csv", na = "", row.names = FALSE)


#Making progress below:
#https://stackoverflow.com/questions/15629885/replace-na-in-column-with-value-in-adjacent-column
#fires_transformed_modis$`20191002`[is.na(fires_transformed_modis$`20191002`)] <- fires_transformed_modis$`20191001`[is.na(fires_transformed_modis$`20191002`)]

#fires_20_years <- read.csv("C:/Users/ABERK/Box/Data_Science_Exploration/ABERK/ABERK_Archive/EarthTime_Archive/2020/01/australia_bushfires/fire_archive_M6_95032_january_2000-september_2019.csv", stringsAsFactors=FALSE)
# #saveRDS(fires_20_years, file = "fire_archive_M6_95032_january_2000-september_2019.rds")
fires_20_years <- readRDS("fire_archive_M6_95032_january_2000-september_2019.rds")

# as.data.frame(table(fires_20_years$daynight))

# appended_df <- read.csv("C:/Users/ABERK/Box/Data_Science_Exploration/ABERK/ABERK_Archive/EarthTime_Archive/2020/01/australia_bushfires/fire_nrt_M6_95412_october_2019-january_2020.csv", stringsAsFactors=FALSE)

# appended_df$type <- NA

# fires_20_years_v1 <- rbind(fires_20_years, appended_df)

#For MODIS, the confidence value ranges from 0% and 100% and can be used to assign one of the three fire classes (low-confidence fire, nominal-confidence fire, or high-confidence fire) to all fire pixels within the fire mask. In some applications errors of commission (or false alarms) are particularly undesirable, and for these applications one might be willing to trade a lower detection rate to gain a lower false alarm rate. Conversely, for other applications missing any fire might be especially undesirable, and one might then be willing to tolerate a higher false alarm rate to ensure that fewer true fires are missed. Users requiring fewer false alarms may wish to retain only nominal- and high-confidence fire pixels, and treat low-confidence fire pixels as clear, non-fire, land pixels. Users requiring maximum fire detectability who are able to tolerate a higher incidence of false alarms should consider all three classes of fire pixels.

#Q. Was it an error? What data source should I trust?
#A: In those circumstances users may need to look for additional clues when there is indication of potential commission error surrounding large wildfires. There have been a few instances involving large and intense wildfires over which tall plumes carrying large volumes of hot material into the air were formed when the VNP14IMG product detected the surface fire along with part of the plume. Those occurrences typically share the following set of conditions:

#(i) Nighttime detection. This is the period during which the VNP14IMG product is particularly responsive to heat sources thereby favoring plume detection;

#(ii) Very large wildfires undergoing explosive growth and accompanied by rapid/vertically elongated plume development. Enough hot material must entrain the plume creating a distinguishable thermal signal (i.e., one that significantly exceeds the fire-free surface background);

#(iii) High scan angle. This is what will ultimately produce the detections extending beyond the actual fire perimeter.

#The parallax effect causes the tall/superheated plume detection pixel(s) to be displaced laterally when projected onto the surface. Displaced pixels will be located on the fire perimeter’s side further away from the image center and closer to the swath’s edge. If those conditions apply, look for alternative observations (previous/next observation) acquired closer to nadir and try and prioritize the use of the fire detection data accordingly. Unfortunately, the VNP14IMG isn’t currently able to distinguish nighttime surface fire pixels from the isolated plume detections due to strong similarities between their radiometric signatures

# fires_20_years_v1 <- fires_20_years_v1[-which(fires_20_years$confidence <= 66),]

# fires_20_years_v1 <- fires_20_years_v1[-which(fires_20_years_v1$daynight == "N"),]

# fires_20_years_v2 <- fires_20_years_v1[,c(1:2,6,13)]

# fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$frp <= 0),]

# fires_20_years_v2$acq_date <- as.Date(fires_20_years_v2$acq_date)
# # fires_20_years_v2$acq_date <- format(fires_20_years_v2$acq_date, "%d %B %Y")

# # # fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "07 January 2020"),]
# # # fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "06 January 2020"),]
# # # fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "05 January 2020"),]
# # # fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "04 January 2020"),]
# # # fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "03 January 2020"),]
# # # fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "02 January 2020"),]
# # # fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "01 January 2020"),]

# fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "2020-01-07"),]
# fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "2020-01-06"),]
# fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "2020-01-05"),]
# fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "2020-01-04"),]
# fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "2020-01-03"),]
# fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "2020-01-02"),]
# fires_20_years_v2 <- fires_20_years_v2[-which(fires_20_years_v2$acq_date == "2020-01-01"),]


# # hist(log(fires_20_years_v2$frp))

# saveRDS(fires_20_years_v2, file = "fires_cleaned.rds")
fires_20_years_v2 <- readRDS("fires_cleaned.rds")
rownames(fires_20_years_v2) <- NULL

#write.csv(fires_20_years_v2, "fires_20_years_v2_cmu_formatting.csv", na = "", row.names = FALSE)

# fires_20_years_v2_scaled <- fires_20_years_v2
# fires_20_years_v2_scaled$frp <- (fires_20_years_v2_scaled$frp/10)
#write.csv(fires_20_years_v2, "fires_20_years_v2_scaled_cmu_formatting.csv", na = "", row.names = FALSE)

# fires_20_years_v2_scaled_by_one_hundred <- fires_20_years_v2
# fires_20_years_v2_scaled_by_one_hundred$frp <- (fires_20_years_v2_scaled_by_one_hundred$frp/100)
# write.csv(fires_20_years_v2_scaled_by_one_hundred, "fires_20_years_v2_scaled_by_100_cmu_formatting.csv", na = "", row.names = FALSE)

fires_20_years_v2_scaled_by_ten_thousand <- fires_20_years_v2
fires_20_years_v2_scaled_by_ten_thousand$frp <- (fires_20_years_v2_scaled_by_ten_thousand$frp/10000)
write.csv(fires_20_years_v2_scaled_by_ten_thousand, "fires_20_years_v2_map_scaled_10000x_cmu_formatting.csv", na = "", row.names = FALSE)

# dfx <- fires_20_years_v2_scaled_by_ten_thousand[order(as.Date(fires_20_years_v2_scaled_by_ten_thousand$acq_date)),]

# dfx[dfx$acq_date=="2010-01-01",]
# dfx[dfx$acq_date=="2009-12-31",]

fires_2000_2009_v2_scaled_by_ten_thousand <- fires_20_years_v2_scaled_by_ten_thousand[1:1092551,]
write.csv(fires_2000_2009_v2_scaled_by_ten_thousand, "fires_2000_2009_v2_map_scaled_10000x_cmu_formatting.csv", na = "", row.names = FALSE)

fires_2010_2019_v2_scaled_by_ten_thousand <- fires_20_years_v2_scaled_by_ten_thousand[1092552:2453344,]
write.csv(fires_2010_2019_v2_scaled_by_ten_thousand, "fires_2010_2019_v2_map_scaled_10000x_cmu_formatting.csv", na = "", row.names = FALSE)

library(reticulate)
use_python("C:/Program Files/Anaconda3/", required = TRUE)
#py_config()
#py_install("pandas")

repl_python()

import array, calendar, csv, math, time

def LonLatToPixelXY(lonlat):
  (lon, lat) = lonlat
  x = (lon + 180.0) * 256.0 / 360.0
  y = 128.0 - math.log(math.tan((lat + 90.0) * math.pi / 360.0)) * 128.0 / math.pi
  return [x, y]

def FormatEpoch(datestr, formatstr):
  return calendar.timegm(time.strptime(datestr, formatstr))
#FormatEpoch("%s-%s-%s" % (year0, month0, day0), '%Y-%m-%d')

def PackColor(color):    
  return color[0] + color[1] * 256.0 + color[2] * 256.0 * 256.0;

def hex2rgb(h):
  return tuple(int(h.strip("#")[i:i+2], 16) for i in (0, 2 ,4))

raw_data = []
#with open("fires_20_years_v2_cmu_formatting.csv", encoding="utf8") as f:
#with open("fires_20_years_v2_scaled_cmu_formatting.csv", encoding="utf8") as f:
with open("fires_20_years_v2_scaled_by_100_cmu_formatting.csv", encoding="utf8") as f:
#with open("fires_20_years_v2_scaled_by_10000_cmu_formatting.csv", encoding="utf8") as f:
  reader = csv.DictReader(f, delimiter=",")
  for row in reader:
    raw_data.append(row)

len(raw_data)

raw_data[0]

# rev 1
# x,y,size_value,epoch
# show all points in same color. Initial date at full size. after n days begin to fade dot until a year as elapsed...
# don't distinguish between events with 0 or > 0 number of events
#This is for **ALL** events
points = []
for row in raw_data:
  x,y = LonLatToPixelXY([float(row['longitude']), float(row['latitude'])])
  points.append(x)
  points.append(y)
  points.append(math.sqrt(float(row['frp']) + 1.0))
  points.append(PackColor([0.85,0.15,0.05]))    
  points.append(FormatEpoch(row["acq_date"], '%d %B %Y'))
#array.array('f', points).tofile(open('two_decades_of_australian_fires.bin', 'wb'))
#array.array('f', points).tofile(open('two_decades_of_australian_fires_scaled.bin', 'wb'))
array.array('f', points).tofile(open('two_decades_of_australian_fires_scaled_by_one_hundred_month_test.bin', 'wb'))
#array.array('f', points).tofile(open('two_decades_of_australian_fires_scaled_by_ten_thousand.bin', 'wb'))


#Note that some people might think that backburning is causing 'ring fires' in the visuals, but these are are most likely due to detection hiatuses, probably caused by cloud cover.