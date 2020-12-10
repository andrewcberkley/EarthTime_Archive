setwd(file.path(Sys.getenv('my_dir'),'2019/10/Global_Protests/'))

library(DBI)
library(bigrquery)
library(stringr)
library(data.table)
library(tidyverse)

project <- "kna-gdelt-practice-set"

sql_v3 <- 'SELECT 
  DATE,
  V2Counts, 
  DOCUMENTIDENTIFIER,
FROM (
  select SPLIT(V2Counts,";") as V2Counts, DOCUMENTIDENTIFIER, DATE
  from [gdelt-bq:gdeltv2.gkg] 
  )
WHERE  
  V2Counts CONTAINS "PROTEST"  
GROUP BY  
  DATE,
  DOCUMENTIDENTIFIER,
  V2Counts'

sql_v4 <- 'SELECT 
  SQLDATE AS Date, 
  ActionGeo_Lat AS Lat, 
  ActionGeo_Long AS Long, 
  SUM(NumArticles) AS NumEvents, 
  EventCode AS EventCode,
  SOURCEURL
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
  EventCode,
  SOURCEURL'

#global_protests_v3_gkg <- query_exec(sql_v3, project = project, max_pages = Inf, useLegacySql = TRUE)
#global_protests_v3_events <- query_exec(sql_v4, project = project, max_pages = Inf, useLegacySql = TRUE)
#saveRDS(global_protests_v3_gkg, file = "raw_global_protests_from_gdelt_v3_gkg.rds")
#saveRDS(global_protests_v3_events, file = "raw_global_protests_from_gdelt_v3_events.rds")
global_protests_v3_gkg <- readRDS("raw_global_protests_from_gdelt_v3_gkg.rds")
global_protests_v3_events <- readRDS("raw_global_protests_from_gdelt_v3_events.rds")

gkg_df <- data.frame(global_protests_v3_gkg,do.call(rbind,str_split(global_protests_v3_gkg$V2Counts,"#")))
colnames(gkg_df) <- c("date", "v2counts", "documentidentifier", "counttype", "count", "objecttype", "locationtype", "locationfullname", "locationcountrycode", "locationadm1code", "locationlatitude", "locationlongitude", "locationfeatureid1", "locationfeatureid2")
events_df <- global_protests_v3_events

merged_dfs <- merge(x = gkg_df, y = events_df, by.x = "documentidentifier", by.y = "SOURCEURL", all = TRUE)
#saveRDS(merged_dfs, file = "events_and_gkg_combined.rds")
events_and_gkg_combined <- readRDS("events_and_gkg_combined.rds")



df2 <- df[,c(1,3:, 11, 12)]

df3 <- df2[-which(df2$date == NA),]
df3 < df2[!is.na(df2$date), ]