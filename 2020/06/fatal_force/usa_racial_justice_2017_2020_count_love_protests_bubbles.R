setwd("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/06/fatal_force/")

library(tidyverse)

countLove <- read.csv("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/06/fatal_force/usa_racial_justice_2017_2020_count_love_protests.csv", sep=",", stringsAsFactors=FALSE)

countLove_wide <- countLove %>%
	group_by(cmu_month_date) %>%
	mutate(idx = row_number()) %>%
	spread(cmu_month_date, Attendees) %>%
	select(-idx)

countLove_clean1 <- countLove_wide[,-c(1:3,5:8)]
#countLove_clean1$'202007' <- NA #Adds one extra month so it doesn't cut off
countLove_clean1$'202007' <- 0 #Adds one extra month so it doesn't cut off

# #https://stackoverflow.com/questions/50521183/r-filling-timeseries-values-but-only-within-last-12-months
# earthtime_zero_fill_placeholder <- function(x,maxgap=1){ #maxgap referes to how many times you'd want to fill over
#  y<-x
#  counter<-0
#  for(i in 2:length(y)){
#    if(is.na(y[i] & counter<maxgap)){
#      y[i]<-y[i-1]
#      counter<-counter+1
#    }else{
#      counter<-0
#    }
#  }
#  return(y)
# }

# countLove_clean1[4:46] <- earthtime_zero_fill_placeholder(countLove_clean1[4:46])
countLove_clean1[is.na(countLove_clean1)] <- 0

write.csv(countLove_clean1, "usa_racial_justice_2017_2020_count_love_protests_wide.csv", row.names = FALSE, na = "")