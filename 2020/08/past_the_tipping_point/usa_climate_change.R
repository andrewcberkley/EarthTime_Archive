library(tidyverse)

setwd("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/08/past_the_tipping_point/")

climdiv_county_year <- read.csv("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/08/past_the_tipping_point/wapo_data_and_analysis/data/processed/climdiv_county_year.csv", stringsAsFactors=FALSE)

climdiv_county_year <- climdiv_county_year[,-c(3)]

#Summertime Temperature Estimates
#climdiv_county_year <- read.csv("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/08/past_the_tipping_point/wapo_data_and_analysis/data/processed/model_county.csv", stringsAsFactors=FALSE)
#climdiv_county_year <- climdiv_county_year[,-c(3)]

et_format <- climdiv_county_year %>%
  group_by(fips, year) %>%
  mutate(idx = row_number()) %>%
  spread(year, tempc) %>%
  select(-idx)

et_format$fips <- sprintf("%05d", as.numeric(et_format$fips))
et_format$fips <- as.character(et_format$fips)
colnames(et_format)[1] <- "GEO_ID"
et_format$GEO_ID <- paste0("0500000US", et_format$GEO_ID)

write.csv(et_format, "usa_fips_climate_change_1895_2019.csv", row.names = FALSE, na = "")

#OMB Region Split
region_i <- dplyr::filter(et_format, grepl("0500000US09|0500000US23|0500000US25|0500000US33|0500000US44|0500000US50",GEO_ID))
region_ii <- dplyr::filter(et_format, grepl("0500000US34|0500000US36|0500000US72",GEO_ID))
region_iii <- dplyr::filter(et_format, grepl("0500000US10|0500000US11|
0500000US24|0500000US42|0500000US51|0500000US54",GEO_ID))
region_iv <- dplyr::filter(et_format, grepl("0500000US01|0500000US12|0500000US13|0500000US21|0500000US28|0500000US37|0500000US45|0500000US47",GEO_ID))
region_v <- dplyr::filter(et_format, grepl("0500000US17|0500000US18|0500000US26|0500000US27|0500000US39|0500000US55",GEO_ID))
region_vi <- dplyr::filter(et_format, grepl("0500000US05|0500000US22|0500000US35|0500000US40|0500000US48",GEO_ID))
region_vii <- dplyr::filter(et_format, grepl("0500000US19|0500000US20|0500000US29|0500000US31",GEO_ID))
region_viii <- dplyr::filter(et_format, grepl("0500000US08|0500000US30|0500000US38|0500000US46|0500000US49|0500000US56",GEO_ID))
region_ix <- dplyr::filter(et_format, grepl("0500000US04|0500000US06|0500000US15|0500000US32|0500000US60|0500000US66|0500000US69|0500000US78",GEO_ID))
region_x <- dplyr::filter(et_format, grepl("0500000US02|0500000US16|0500000US41|0500000US53",GEO_ID))

rm(et_format)
rm(climdiv_county_year)

files <- mget(ls())

for (i in 1:length(files)){
  write.csv(files[[i]], paste(names(files[i]), "_usa_omb_standard_federal.csv", sep = ""))
}