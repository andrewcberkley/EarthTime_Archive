setwd(file.path(Sys.getenv('my_dir'),'2020/01/australia_bushfires/'))

# library(tidyverse)
# library(zoo)

fires_nrt <- read.csv("DL_FIRE_M6_14122020/fire_nrt_M6_170679.csv", stringsAsFactors=FALSE) #Dec 14th 2020 Update
fires_archived <- read.csv("DL_FIRE_M6_14122020/fire_archive_M6_170679.csv", stringsAsFactors=FALSE)
fires_archived <- fires_archived[,-15]

fires_2020_v1 <- rbind(fires_archived,fires_nrt)

#For MODIS, the confidence value ranges from 0% and 100% and can be used to assign one of the three fire classes (low-confidence fire, nominal-confidence fire, or high-confidence fire) to all fire pixels within the fire mask. In some applications errors of commission (or false alarms) are particularly undesirable, and for these applications one might be willing to trade a lower detection rate to gain a lower false alarm rate. Conversely, for other applications missing any fire might be especially undesirable, and one might then be willing to tolerate a higher false alarm rate to ensure that fewer true fires are missed. Users requiring fewer false alarms may wish to retain only nominal- and high-confidence fire pixels, and treat low-confidence fire pixels as clear, non-fire, land pixels. Users requiring maximum fire detectability who are able to tolerate a higher incidence of false alarms should consider all three classes of fire pixels.

#Q. Was it an error? What data source should I trust?
#A: In those circumstances users may need to look for additional clues when there is indication of potential commission error surrounding large wildfires. There have been a few instances involving large and intense wildfires over which tall plumes carrying large volumes of hot material into the air were formed when the VNP14IMG product detected the surface fire along with part of the plume. Those occurrences typically share the following set of conditions:

#(i) Nighttime detection. This is the period during which the VNP14IMG product is particularly responsive to heat sources thereby favoring plume detection;

#(ii) Very large wildfires undergoing explosive growth and accompanied by rapid/vertically elongated plume development. Enough hot material must entrain the plume creating a distinguishable thermal signal (i.e., one that significantly exceeds the fire-free surface background);

#(iii) High scan angle. This is what will ultimately produce the detections extending beyond the actual fire perimeter.

#The parallax effect causes the tall/superheated plume detection pixel(s) to be displaced laterally when projected onto the surface. Displaced pixels will be located on the fire perimeter’s side further away from the image center and closer to the swath’s edge. If those conditions apply, look for alternative observations (previous/next observation) acquired closer to nadir and try and prioritize the use of the fire detection data accordingly. Unfortunately, the VNP14IMG isn’t currently able to distinguish nighttime surface fire pixels from the isolated plume detections due to strong similarities between their radiometric signatures

fires_2020_v1 <- fires_2020_v1[-which(fires_2020_v1$confidence <= 66),]

fires_2020_v1 <- fires_2020_v1[-which(fires_2020_v1$daynight == "N"),]

fires_2020_v2 <- fires_2020_v1[,c(1:2,6,13)]

fires_2020_v2 <- fires_2020_v2[-which(fires_2020_v2$frp <= 0),]

#fires_2020_v2$acq_date <- as.Date(fires_2020_v2$acq_date, "%d-%B-%Y")
fires_2020_v2$acq_date <- format(fires_2020_v2$acq_date, "%d %B %Y")

#hist(log(fires_2020_v2$frp))

saveRDS(fires_2020_v2, file = "fires_cleaned_2020.rds")
fires_2020_v2 <- readRDS("fires_cleaned_2020.rds")
rownames(fires_2020_v2) <- NULL

write.csv(fires_2020_v2, "fires_dec_2020_update.csv", na = "", row.names = FALSE)

fires_2020_dec_update_scaled <- fires_2020_v2
fires_2020_dec_update_scaled$frp <- (fires_2020_dec_update_scaled$frp/10000)
#fires_2020_dec_update_scaled$acq_date <- as.Date(fires_2020_dec_update_scaled$acq_date)
write.csv(fires_2020_dec_update_scaled, "fires_2020_v2_cmu_formatting_dec_2020_update.csv", na = "", row.names = FALSE)

library(reticulate)
use_python("C:/Program Files/Anaconda3/", required = TRUE)

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
with open("fires_2020_v2_cmu_formatting_dec_2020_update.csv", encoding="utf8") as f:
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
array.array('f', points).tofile(open('2020_australia_fire_december_update.bin', 'wb'))

#Note that some people might think that backburning is causing 'ring fires' in the visuals, but these are are most likely due to detection hiatuses, probably caused by cloud cover.