setwd(file.path(Sys.getenv('my_dir'),'2020/05/mobility_after_covid/'))

library(tidyverse)
library(zoo)

#DL_us_m50_index <- read.csv("Descartes_Labs-COVID-19-master/DL-us-m50_index.csv", stringsAsFactors=FALSE)
#View(DL_us_m50_index)

DL_us_m50_index <- read.csv("https://raw.githubusercontent.com/descarteslabs/DL-COVID-19/master/DL-us-m50_index.csv", stringsAsFactors=FALSE)

destroyX = function(df) {
  #https://stackoverflow.com/questions/10441437/why-am-i-getting-x-in-my-column-names-when-reading-a-data-frame
  f = df
  for (col in c(1:ncol(f))){ #for each column in dataframe
    if (startsWith(colnames(f)[col], "X") == TRUE)  { #if starts with 'X' ..
      colnames(f)[col] <- substr(colnames(f)[col], 2, 100) #get rid of it
    }
  }
  assign(deparse(substitute(df)), f, inherits = TRUE) #assign corrected data to original name
}

destroyX(DL_us_m50_index)

colnames(DL_us_m50_index) <- gsub("\\.", "", colnames(DL_us_m50_index))

df <- DL_us_m50_index[!(DL_us_m50_index$admin2==""),]

df$fips <- sprintf("%05d", as.numeric(df$fips))

final_df <- df[,-c(1:4)]

final_df$fips <- as.character(final_df$fips)

colnames(final_df)[1] <- "GEO_ID"

long <- gather(final_df, "date", "index_measurement", 2:76)
long_v2 <- long[order(long[,"GEO_ID"]), ]
rownames(long_v2) <- NULL

long_v3 <- long_v2 %>%
  group_by(GEO_ID) %>%
  mutate(filled_measurements = na.approx(index_measurement, na.rm=FALSE)) 

long_v4 <- long_v3[c(1,2,4)]

long_v4$GEO_ID <- paste0("0500000US", long_v4$GEO_ID)

true_final_df <- long_v4 %>%
  group_by(date) %>%
  mutate(idx = row_number()) %>%
  spread(date, filled_measurements) %>%
  select(-idx)

wide_minus <- true_final_df[,-c(1)]
wide_filled_over <- t(apply(wide_minus, 1, function(x) na.locf(x, fromLast = F, na.rm = F)))
wide_plus <- true_final_df[,c(1)]
wide_final_final <- cbind(wide_plus, wide_filled_over)

california_counties <- dplyr::filter(wide_final_final, grepl("0500000US06",GEO_ID))
tri_state_area_counties <- dplyr::filter(wide_final_final, grepl("0500000US42|0500000US36|0500000US34|0500000US09|0500000US25|0500000US44|0500000US50|0500000US33|0500000US23",GEO_ID)) 

partial_south_and_west_counties <- dplyr::filter(wide_final_final, grepl("0500000US01|0500000US04|0500000US05|0500000US12|0500000US13|0500000US20|0500000US21|0500000US22|0500000US28|0500000US29|0500000US35|0500000US40|0500000US47|0500000US48",GEO_ID))
partial_midwest_and_rust_belt_counties <- dplyr::filter(wide_final_final, grepl("0500000US55|0500000US19|0500000US17|0500000US18|0500000US39|0500000US26|0500000US42|0500000US29|0500000US21|0500000US54|0500000US27",GEO_ID))

# write.csv(wide_final_final, "descartes_labs_mobility.csv", row.names = FALSE, na = "")
# write.csv(california_counties, "descartes_labs_mobility_california_counties.csv", row.names = FALSE, na = "")
# write.csv(tri_state_area_counties, "descartes_labs_mobility_tri_state_area_counties.csv", row.names = FALSE, na = "")
# write.csv(partial_south_and_west_counties, "descartes_labs_mobility_partial_south_and_west_counties.csv", row.names = FALSE, na = "")
# write.csv(partial_midwest_and_rust_belt_counties, "descartes_labs_mobility_partial_midwest_and_rust_belt_counties.csv", row.names = FALSE, na = "")

write.csv(wide_final_final, "descartes_labs_mobility_14122020.csv", row.names = FALSE, na = "")
write.csv(california_counties, "descartes_labs_mobility_california_counties_14122020.csv", row.names = FALSE, na = "")
write.csv(tri_state_area_counties, "descartes_labs_mobility_tri_state_area_counties_14122020.csv", row.names = FALSE, na = "")
write.csv(partial_south_and_west_counties, "descartes_labs_mobility_partial_south_and_west_counties_14122020.csv", row.names = FALSE, na = "")
write.csv(partial_midwest_and_rust_belt_counties, "descartes_labs_mobility_partial_midwest_and_rust_belt_counties_14122020.csv", row.names = FALSE, na = "")