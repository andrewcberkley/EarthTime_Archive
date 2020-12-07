setwd(file.path(Sys.getenv('my_dir'),'2020/11/machine_metrics/'))

library(dplyr)
library(stringr)
library(data.table)
library(tidyverse)

machine_metrics <- read.csv("data_all_regions.csv", header=FALSE, stringsAsFactors=FALSE)

#r grep 'n' characters after and before match
#https://stackoverflow.com/questions/48449812/r-grep-n-characters-after-and-before-match
#x <- "rolling: NA<br />day: 2017-12-02<br />region: South"
#stringr::str_extract(x, ".{0,0}day.{0,12}")

#Replace all occurrences of a string in a data frame
#https://stackoverflow.com/questions/29271549/replace-all-occurrences-of-a-string-in-a-data-frame
get_date <-  function(x){
  str_extract(x, ".{0,0}day.{0,12}")
}

just_dates <- mutate_all(machine_metrics, funs(get_date))

#Deleting first few rows and change the header names to row values
#https://stackoverflow.com/questions/46594937/deleting-first-few-rows-and-change-the-header-names-to-row-values
names(machine_metrics) <- just_dates[1,]
rm(just_dates)
rm(get_date)

colnames(machine_metrics) <- gsub("-", "", colnames(machine_metrics))
colnames(machine_metrics) <- gsub("day: ", "", colnames(machine_metrics))

#rm(machine_metrics)

rolling_df <- data.frame(lapply(machine_metrics, function(x) {
  gsub("<.*","",x)
  }))

cleaner_df <- data.frame(lapply(rolling_df, function(x) {
  gsub("rolling: ","",x)
}))

rm(rolling_df)

colnames(cleaner_df)[1] <- "location"

colnames(cleaner_df) <- gsub("X", "", colnames(cleaner_df))

final_df <- cleaner_df[,-c(2:7)]
rm(cleaner_df)

names(final_df) <- substring(names(final_df),1,6) #remove day
colnames(final_df)[1] <- "location"

long <- melt(setDT(final_df), id.vars = c("location"), variable.name = "date")

long[,3] <- as.numeric(long[,3])

longer <- long %>%
	group_by(location, date) %>%
	summarise(value = mean(value, na.rm = TRUE))

colnames(longer)[3] <- "utilization"

finalest_df <- longer %>% 
  group_by(location, date) %>% 
  mutate(idx = row_number()) #%>% 
  #spread(utilization) %>% 
  #select(-idx)

write.csv(final_df, "machine_metrics_data_cleaned_wide_v3.csv", row.names = FALSE, na = "")