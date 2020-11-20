setwd("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/10/nr2_china_fundraising/")

library(tidyverse)
library(zoo)
library(jsonlite)

cn_lat_long <- read.csv("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/09/nr2_china_fundraising/cn_lat_long.csv", stringsAsFactors=FALSE)
cn_lat_long_v2 <- cn_lat_long[,c(1,6,2,3)]
colnames(cn_lat_long_v2)[1] <- "location"

fundraised_2017_2020 <- readxl::read_xlsx("nr2 - China_fundraised_2017-2020.xlsx")
colnames(fundraised_2017_2020)[1] <- "Date"
long_china_df <- reshape2::melt(fundraised_2017_2020, id.vars=c("Date"))
colnames(long_china_df) <- c("date", "location", "funding_amount")

long_china_df_v2 <- long_china_df

json_data <- fromJSON("location_coordinate_20201016.json", flatten = TRUE)

#https://stackoverflow.com/questions/50091610/convert-triple-nested-list-to-dataframe
x = unstack(data.frame(d<-unlist(json_data),names(d)))

#https://stackoverflow.com/questions/29511215/convert-row-names-into-first-column
library(data.table)
china_lat_long <- setDT(x, keep.rownames = TRUE)[]

#https://stackoverflow.com/questions/4350440/split-data-frame-string-column-into-multiple-columns
#library(stringr)
#str_split_fixed(china_lat_long$rn, ".lat|.lng", 3)

china_lat_long$coordinates <- NA

#https://stackoverflow.com/questions/49428244/r-copy-string-to-column-if-contained-in-another-column
china_lat_long$coordinates <- ifelse(grepl(".lat", china_lat_long$rn), "latitude", "longitude")
#china_lat_long$coordinates <- ifelse(grepl(".lng", china_lat_long$rn), "lng", NA)

china_lat_long$rn <- sub("*\\.lat", "", china_lat_long$rn)
china_lat_long$rn <- sub("*\\.lng", "", china_lat_long$rn)

china_lat_long$rn <- gsub("\\.", "-", china_lat_long$rn)

#https://stackoverflow.com/questions/4350440/split-data-frame-string-column-into-multiple-columns
library(stringr)
admin_split <- as.data.frame(str_split_fixed(china_lat_long$rn, "-", 2))

china_with_admins <- cbind(china_lat_long, admin_split)

dat1 <- china_with_admins %>% mutate_all(na_if,"")

dat1$almost <- paste0(dat1$V2, ", ", dat1$V1)
dat1$almost <- gsub("NA, ","",dat1$almost)
cleaner_df <- dat1[,c(2,3,6)]

china_clean <- cleaner_df %>%
  group_by(almost) %>%
  mutate(idx = row_number()) %>%
  spread(coordinates, res) %>%
  select(-idx)

#https://stackoverflow.com/questions/43345821/how-to-collapse-rows-of-data
china_coords_final <- setDT(china_clean)[, lapply(.SD, function(x)
{x <- unique(x[!is.na(x)])
if(length(x) == 1) as.character(x)
else if(length(x) == 0) NA_character_
else "multiple"}),
by=almost]

colnames(china_coords_final) <- c("location", "latitude", "longitude")

#long_china_df_v2[2] <- gsub(" District,.*", "", long_china_df$location)

base1 <- as.data.frame(merge(china_coords_final, long_china_df_v2, by = 'location'))
base1[4] <- gsub("-", "", base1$date)
#base1_v2 <- base1[,-c(2)]

china_funding_wide <- base1 %>%
  group_by(date, location, latitude, longitude) %>%
  mutate(idx = row_number()) %>%
  spread(date, funding_amount) %>%
  select(-idx)

china_funding_wide[is.na(china_funding_wide)] = 0

rm(list= ls()[!(ls() %in% "china_funding_wide")])

china_funding_wide_minus <- china_funding_wide[,-c(1:3)]

china_funding_sums <- china_funding_wide_minus %>%
  mutate(id = 1:nrow(.)) %>% # adding an ID to identify groups
  gather(date, value, -id) %>% # wide to long format
  arrange(id, date) %>%
  group_by(id) %>%
  mutate(value = cumsum(value)) %>%
  ungroup() %>%
  spread(date, value) %>% # long to wide format
  select(-id)

china_funding_wide_plus <- china_funding_wide[,c(1:3)]
final_df <- cbind.data.frame(china_funding_wide_plus, china_funding_sums)

write.csv(final_df, "china_funding_nr2_v2.csv", row.names = FALSE, na = "")