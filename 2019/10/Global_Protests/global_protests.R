setwd(file.path(Sys.getenv('my_dir'),'2019/10/Global_Protests/'))

#A Word of Caution for using GDELT Data
#Just because the number of events of a certain phenomenon increases as the years progress, does not mean that the phenomenon increases. It may just mean that more data has become available, or that more sources respond to the phenomenon.
#The data is not curated, no human being has selected the relevant pieces from the irrelevant.
#In many instances the specific actors are unknown.

#The GDELT dataset is built around automated content analysis of news articles (i.e. newspapers, online news sources, etc.). The dataset is large enough to require automation to find different pieces of information (Actor1, Actor2, Tone, etc.). The automation requires that the text sources are uploaded to a computer and run through a specific algorithm designed to extract and code events that are referred to in news sources. The coding decisions would ideally be available to other researchers so that other people or alternative algorithmic approaches could check a subset of the coding decisions. The creators of the GDELT do not allow for third-party verification: they do not release the articles nor do they list the article sources and dates. Kalev Leetaru has previously mentioned that, “our licensing restrictions are quite tight on the data and we cannot make the text available.” This struck us as odd given that most of the sources are publicly available news reports, but more importantly if the underlying data cannot be shared it imperils notions of transparency and replication central to science. Even if one were to attempt to recreate the entire dataset, the existing codebooks and papers about GDELT do not even identify which text sources are utilized for each year. The lack of transparency in the data collection process is a significant barrier to independent validation of the constructs.

#remotes::install_github("r-dbi/DBI")
#remotes::install_github("r-dbi/bigrquery")

library(DBI)
library(bigrquery)
library(stringr)
library(data.table)
library(tidyverse)
#library(zoo)

project <- "kna-gdelt-practice-set"

#For the SQL code below, please note the following:
#The "substr()" is used to chop the date down to monthly resolution (YYYYMM)
#The "EventRootCode='14'" narrows to all protest-related events
#THe "ActionGeo_Type>1" excludes country-level matches (only matches for specific administrative divisions, cities, and individual buildings/landmarks are returned), 
#The "ABS()" command checks filter out a handful of records with corrupt geographic data
#The "NumArticles>4" command ensures that only those events for which the algorithms are highly confident in their identification are displayed (this reduces visibility of breaking events, but offers a reasonable filter)

#sql <- 'SELECT 
#  SQLDATE AS Date, 
#  ActionGeo_Lat AS Lat, 
#  ActionGeo_Long AS Long, 
#  SUM(NumArticles) AS NumEvents 
#FROM 
#  [gdelt-bq:gdeltv2.events] 
#WHERE  
#  EventRootCode="14"
#  AND ActionGeo_Type>1 
#  AND (ABS(ActionGeo_Lat) > 0 
#    OR ABS(ActionGeo_Long) > 0) 
#  AND NumArticles>4 
#GROUP BY  
#  Date,  
#  Lat,  
#  Long'

#global_protests <- query_exec(sql, project = project, max_pages = Inf, useLegacySql = TRUE)
#saveRDS(global_protests, file = "coded_global_protests_from_gdelt.rds")
#global_protests <- readRDS("coded_global_protests_from_gdelt.rds")

#Another note on "NumArticles" and how it differs from "NumMentions" and "NumSources"
#"NumArticles" is total number of source documents containing one or more mentions of this event during the 15 minute update in which it was first seen
#"NumMentions"	is the total number of mentions of this event across all source documents during the 15 minute update in which it was first seen. event within a single document also contribute to this count Multiple references to an event
#"NumSources" is total number of information sources containing one or more mentions of this event during the 15 minute update in which it was first seen
#We had considered using the "GoldsteinScale", which is, on a scale from, "-10 to +10, capture[s] the theoretical potential impact that type of event will have on the stability of a country". We ultimately decided against it because it focused on "perceived impact", which we were not confident as a reliable measure of "actual impact"

#Another thing to keep in mind: "NumMentions" tallies the total number of mentions in all articles (it’s the same or higher than "NumArticles" because some articles mention the same event twice).

sql_v2 <- 'SELECT 
  SQLDATE AS Date, 
  ActionGeo_Lat AS Lat, 
  ActionGeo_Long AS Long, 
  SUM(NumArticles) AS NumEvents, 
  EventCode AS EventCode
FROM 
  [gdelt-bq:gdeltv2.events] 
WHERE  
  EventRootCode="14"
  AND ActionGeo_Type>1 
  AND (ABS(ActionGeo_Lat) > 0 
    OR ABS(ActionGeo_Long) > 0) 
  AND NumArticles>4 
GROUP BY  
  Date,  
  Lat,  
  Long,
  EventCode'

#global_protests_v2 <- query_exec(sql_v2, project = project, max_pages = Inf, useLegacySql = TRUE)
#saveRDS(global_protests_v2, file = "raw_global_protests_from_gdelt_v2.rds")
coded_global_protests <- readRDS("raw_global_protests_from_gdelt_v2.rds")


gdelt_protests_codes <- data.table(EventCode = c(14, 140, 141, 1411, 1412, 1413, 1414, 142, 1421, 1422, 1423, 1424, 143, 1431, 1432, 1433, 1434, 144, 1441, 1442, 1443, 1444, 145, 1451, 1452, 1453, 1454), EventLabel = c("PROTEST", "Engage in political dissent, not specifed below", "Demonstrate or rally, not specifed below", "Demonstrate for leadership change", "Demonstrate for policy change", "Demonstrate for rights", "Demonstrate for change in institutions, regime", "Conduct hunger strike, not specifed below", "Conduct hunger strike for leadership change", "Conduct hunger strike for policy change", "Conduct hunger strike for rights", "Conduct hunger strike for change in institutions, regime", "Conduct strike or boycott, not specifed below", "Conduct strike or boycott for leadership change", "Conduct strike or boycott for policy change", "Conduct strike or boycott for rights", "Conduct strike or boycott for change in institutions, regime", "Obstruct passage, block, not specifed below", "Obstruct passage to demand leadership change", "Obstruct passage to demand policy change", "Obstruct passage to demand rights", "Obstruct passage to demand change in institutions, regime", "Protest violently, riot, not specifed below", "Engage in violent protest for leadership change", "Engage in violent protest for policy change", "Engage in violent protest for rights", "Engage in violent protest for change in institutions, regime"), JOHL_Label = c("PROTEST", "Political dissent", "Demonstration or Rally", "Demonstration or Rally", "Demonstration or Rally", "Demonstration or Rally", "Demonstration or Rally", "Hunger Strike", "Hunger Strike", "Hunger Strike", "Hunger Strike", "Hunger Strike", "Strike or Boycott", "Strike or Boycott", "Strike or Boycott", "Strike or Boycott", "Strike or Boycott", "Obstruct Passage", "Obstruct Passage", "Obstruct Passage", "Obstruct Passage", "Obstruct Passage", "Violent Protest or Riots", "Violent Protest or Riots", "Violent Protest or Riots", "Violent Protest or Riots", "Violent Protest or Riots"))

#Beijing's GDELT latitude & longitude = 39.9289, 116.388
#Hong Kong's GDELT latitude & logitude = 22.2833, 114.183
#After review, it appears that GDELT is classifying many of the Hong Kong protests as occuring in Beijing. We believe that this is occuring because of an NLP error where the algorithm incorrectly classifies articles with titles such as "" or "" as occuring in Beijing instead of Hong Kong. After further review and much deliberation, we are deliberatly replacing the most frequently occuring Beijing coordinates to the most frequently occuring Hong Kong coordinates. 
coded_global_protests[coded_global_protests==39.9289] <- 22.2833 #Hong Kong Protests Latitude Fix
coded_global_protests[coded_global_protests==116.388] <- 114.183 #Hong Kong Protests Longitude Fix

coded_global_protests$EventLabel <- gdelt_protests_codes$EventLabel[match(coded_global_protests$EventCode, gdelt_protests_codes$EventCode)]
coded_global_protests$JOHL_Label <- gdelt_protests_codes$JOHL_Label[match(coded_global_protests$EventCode, gdelt_protests_codes$EventCode)]
unique(coded_global_protests$EventLabel)
as.data.frame(table(coded_global_protests$EventLabel))
as.data.frame(table(coded_global_protests$JOHL_Label))
#global_protests$type <- "protests"
coded_global_protests <- coded_global_protests[order(-coded_global_protests$Date),]
rownames(coded_global_protests) <- NULL
class(coded_global_protests$Date)
#**************Specific Type of Protest Bubble Break***************************
specific_protests <- coded_global_protests[!grepl("not specifed below", coded_global_protests$EventLabel),]
specific_protests$Date <- str_sub(specific_protests$Date, end=-3)
bubble_df <- specific_protests %>%
	group_by(Date) %>%
	mutate(idx = row_number()) %>%
	spread(Date, NumEvents) %>%
	select(-idx)
bubble_df2 <- bubble_df[,-c(3,5:11)]
bubble_df2$'201501' <- NA
bubble_df3 <- bubble_df2[,c(3,1,2,63,4:62)]

#bubble_df3[4:61] <- t(apply(bubble_df3[4:61], 1, function(x) na.locf(x, fromLast = F, na.rm = F))) #use went wanting to fill to end with the same value

# #https://stackoverflow.com/questions/50521183/r-filling-timeseries-values-but-only-within-last-12-months
# earthtime_zero_fill_placeholder <- function(x,maxgap=1){ #maxgap referes to how many times you'd want to fill over
#   y<-x
#   counter<-0
#   for(i in 2:length(y)){
#     if(is.na(y[i] & counter<maxgap)){
#       y[i]<-y[i-1]
#       counter<-counter+1
#     }else{
#       counter<-0
#     }
#   }
#   return(y)
# }

#bubble_df3[4:61] <- earthtime_zero_fill_placeholder(bubble_df3[4:61])
bubble_df3[is.na(bubble_df3)] <- 0
#bubble_df2 <- select(filter(bubble_df, JOHL_Label == "Violent Protest or Riots"),c(1:123))

themeList <- split(bubble_df3, bubble_df3$EventLabel)
for (i in seq_along(themeList)) {
    try({
        filename = paste(names(themeList)[i], ".csv")
        write.csv(themeList[[i]], filename, na = "", row.names = FALSE)
    })
}

write.csv(bubble_df3, "half_decade_of_protests_v2.csv", na = "", row.names = FALSE)
#**************End Specific Type of Protest Bubble Break***************************

specific_coded_global_protests <- coded_global_protests[!grepl("not specifed below", coded_global_protests$EventLabel),]
specific_coded_global_protests$Date <- gsub("(\\d{4})(\\d{2})(\\d{2})$","\\1-\\2-\\3",specific_coded_global_protests$Date)
specific_coded_global_protests$Date <- as.Date(specific_coded_global_protests$Date)
specific_coded_global_protests$Date <- format(specific_coded_global_protests$Date, "%d %B %Y")
colnames(specific_coded_global_protests) <- c("event_date", "latitude", "longitude", "number_of_events", "event_code", "event_label", "JOHL_Label")

hist(log(specific_coded_global_protests$number_of_events))

write.csv(specific_coded_global_protests, "coded_global_protests_cmu_formatting_v2.csv", na = "", row.names = FALSE)

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
with open("coded_global_protests_cmu_formatting_v2.csv", encoding="utf8") as f:
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
  points.append(math.sqrt(float(row['number_of_events']) + 1.0))
  points.append(PackColor([0.85,0.15,0.05]))    
  points.append(FormatEpoch(row["event_date"], '%d %B %Y'))
array.array('f', points).tofile(open('global_protests_2015-2019.bin', 'wb'))

# #The below is for **SPECIFIC** types of events

# #event_type_categories_rgb = {
# #  "Demonstration or Rally": #Amethyst [0.6, 0.4, 0.8]
# #  "Hunger Strike": #Apple Green [0.55, 0.71, 0.0]
# #  "Obstruct Passage": #Banana Yellow [1.0, 0.88, 0.21]
# #  "Political dissent":  #Boston University Red [0.8, 0.0, 0.0]
# #  "Strike or Boycott":  #Cadium Orange [0.93, 0.53, 0.18]
# #  "Violent Protest or Riots": #Fuchsia Pink [1.0, 0.47, 1.0]
# #}

# #Demonstration or Rally
# points = []
# for row in raw_data:
#   if row['JOHL_Label'] ==  "Demonstration or Rally":    
#     x,y = LonLatToPixelXY([float(row['longitude']), float(row['latitude'])])
#     points.append(x)
#     points.append(y)
#     points.append(math.sqrt(float(row['number_of_events']) + 1.0))
#     points.append(PackColor([0.6, 0.4, 0.8]))    
#     points.append(FormatEpoch(row["event_date"], '%d %B %Y'))
# array.array('f', points).tofile(open('demonstration_or_rally.bin', 'wb'))

# #Hunger Strike
# points = []
# for row in raw_data:
#   if row['JOHL_Label'] ==  "Hunger Strike":    
#     x,y = LonLatToPixelXY([float(row['longitude']), float(row['latitude'])])
#     points.append(x)
#     points.append(y)
#     points.append(math.sqrt(float(row['number_of_events']) + 1.0))
#     points.append(PackColor([0.55, 0.71, 0.0]))    
#     points.append(FormatEpoch(row["event_date"], '%d %B %Y'))
# array.array('f', points).tofile(open('hunger_strike.bin', 'wb'))

# #Obstruct Passage
# points = []
# for row in raw_data:
#   if row['JOHL_Label'] ==  "Obstruct Passage":    
#     x,y = LonLatToPixelXY([float(row['longitude']), float(row['latitude'])])
#     points.append(x)
#     points.append(y)
#     points.append(math.sqrt(float(row['number_of_events']) + 1.0))
#     points.append(PackColor([1.0, 0.88, 0.21]))    
#     points.append(FormatEpoch(row["event_date"], '%d %B %Y'))
# array.array('f', points).tofile(open('obstruct_passage.bin', 'wb'))

# #Political dissent
# points = []
# for row in raw_data:
#   if row['JOHL_Label'] ==  "Political dissent":    
#     x,y = LonLatToPixelXY([float(row['longitude']), float(row['latitude'])])
#     points.append(x)
#     points.append(y)
#     points.append(math.sqrt(float(row['number_of_events']) + 1.0))
#     points.append(PackColor([0.8, 0.0, 0.0]))    
#     points.append(FormatEpoch(row["event_date"], '%d %B %Y'))
# array.array('f', points).tofile(open('political_dissent.bin', 'wb'))

# #Strike or Boycott
# points = []
# for row in raw_data:
#   if row['JOHL_Label'] ==  "Strike or Boycott":    
#     x,y = LonLatToPixelXY([float(row['longitude']), float(row['latitude'])])
#     points.append(x)
#     points.append(y)
#     points.append(math.sqrt(float(row['number_of_events']) + 1.0))
#     points.append(PackColor([0.93, 0.53, 0.18]))    
#     points.append(FormatEpoch(row["event_date"], '%d %B %Y'))
# array.array('f', points).tofile(open('strike_or_boycott.bin', 'wb'))

# #Violent Protest or Riots
# points = []
# for row in raw_data:
#   if row['JOHL_Label'] ==  "Violent Protest or Riots":    
#     x,y = LonLatToPixelXY([float(row['longitude']), float(row['latitude'])])
#     points.append(x)
#     points.append(y)
#     points.append(math.sqrt(float(row['number_of_events']) + 1.0))
#     points.append(PackColor([1.0, 0.47, 1.0]))    
#     points.append(FormatEpoch(row["event_date"], '%d %B %Y'))
# array.array('f', points).tofile(open('violent_protest_or_riot.bin', 'wb'))

# #End