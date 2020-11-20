setwd("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/07/paycheck_protection_program/")

completeFun <- function(data, desiredCols) {
  completeVec <- complete.cases(data[, desiredCols])
  return(data[completeVec, ])
}

library(tidyverse)

PPP.Data.150k.plus <- read.csv("150k_plus/PPP Data 150k plus.csv", stringsAsFactors = FALSE)

as.data.frame(table(PPP.Data.150k.plus$BusinessType))
as.data.frame(table(PPP.Data.150k.plus$LoanRange))

PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == "NEW YORK CITY"] <- "NEW YORK"
PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == "BRONX"] <- "NEW YORK"
PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == "BROOKYLN"] <- "NEW YORK"
PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == "MANHATTAN"] <- "NEW YORK"
PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == "QUEENS"] <- "NEW YORK"
PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == "STATEN ISLAND"] <- "NEW YORK"
PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == "LONG ISLAND"] <- "NEW YORK"
PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == "NEW YORK,"] <- "NEW YORK"
PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == "NEW YORK S"] <- "NEW YORK"
PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == "NEW YORK NY"] <- "NEW YORK"
PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == "INWOOD NEW YORK"] <- "NEW YORK"
PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == "NEW YORK CITY"] <- "NEW YORK"
PPP.Data.150k.plus$City[PPP.Data.150k.plus$City == ", BROOKLYN"] <- "NEW YORK"

corps_and_mom_pop <- PPP.Data.150k.plus[which(PPP.Data.150k.plus$BusinessType == "Corporation"|PPP.Data.150k.plus$BusinessType == "Sole Proprietorship") , ]

#gsub issues due to "$" resolved with backslash
#https://stackoverflow.com/questions/34508264/replacing-a-value-with-gsub-does-not-seem-to-work
#Replacing the range with the loan range with the arithmetic mean
corps_and_mom_pop$LoanRange <- gsub("a \\$5-10 million", "7500000", corps_and_mom_pop$LoanRange)
corps_and_mom_pop$LoanRange <- gsub("b \\$2-5 million", "3500000", corps_and_mom_pop$LoanRange)
corps_and_mom_pop$LoanRange <- gsub("c \\$1-2 million", "1500000", corps_and_mom_pop$LoanRange)
corps_and_mom_pop$LoanRange <- gsub("d \\$350,000-1 million", "675000", corps_and_mom_pop$LoanRange)
corps_and_mom_pop$LoanRange <- gsub("e \\$150,000-350,000", "250000", corps_and_mom_pop$LoanRange)

#numbers using the arithmetic mean above seem too high, going to use the minmum amount--a conservative estimate 
#corps_and_mom_pop$LoanRange <- gsub("a \\$5-10 million", "5000000", corps_and_mom_pop$LoanRange)
#corps_and_mom_pop$LoanRange <- gsub("b \\$2-5 million", "2000000", corps_and_mom_pop$LoanRange)
#corps_and_mom_pop$LoanRange <- gsub("c \\$1-2 million", "1000000", corps_and_mom_pop$LoanRange)
#corps_and_mom_pop$LoanRange <- gsub("d \\$350,000-1 million", "350000", corps_and_mom_pop$LoanRange)
#corps_and_mom_pop$LoanRange <- gsub("e \\$150,000-350,000", "150000", corps_and_mom_pop$LoanRange)
##scratch that


corps_and_mom_pop$LoanRange <- as.numeric(corps_and_mom_pop$LoanRange)

corps_and_mom_pop_v2 <- corps_and_mom_pop[,c(1,4,5,8,13,14)]
corps_and_mom_pop_v2$city_state <- paste0(corps_and_mom_pop_v2$City,"-",corps_and_mom_pop_v2$State)
corps_and_mom_pop_v2 <- corps_and_mom_pop_v2[,-c(2:3)]

###################
###Loans Range###
###################

city_loan_sums <- corps_and_mom_pop_v2[,-c(3)]
city_loan_sums_v2 <- city_loan_sums %>% 
  group_by(BusinessType, DateApproved, city_state) %>% 
  summarise(LoanRange = sum(LoanRange))

city_loan_sums_v3 <- city_loan_sums_v2 %>%
  group_by(BusinessType, DateApproved, city_state) %>%
  mutate(idx = row_number()) %>%
  spread(DateApproved, LoanRange) %>%
  select(-idx)

city_loan_sums_v3[is.na(city_loan_sums_v3)] <- 0

city_loan_sums_v3$"04/17/2020" <- 0
city_loan_sums_v3$"04/18/2020" <- 0
city_loan_sums_v3$"04/19/2020" <- 0
city_loan_sums_v3$"04/20/2020" <- 0
city_loan_sums_v3$"04/21/2020" <- 0
city_loan_sums_v3$"04/22/2020" <- 0
city_loan_sums_v3$"04/23/2020" <- 0
city_loan_sums_v3$"04/24/2020" <- 0
city_loan_sums_v3$"04/25/2020" <- 0
city_loan_sums_v3$"04/26/2020" <- 0

city_loan_sums_v3 <- city_loan_sums_v3[,c(1:16,82:91,17:81)]

city_loan_sums_v3$id <- 1:20063 #here

city_loan_sums_v3_aggregated <- city_loan_sums_v3 %>%
  #mutate(id = 1:nrow(.)) %>% #adding an id to identify groups
  #Error: Column `id` must be length 1 (the group size), not 20063 #was getting the following error, so added id column independendtly a few lines aboves see "here"
  gather(DateApproved, LoanRange, -id) %>% #wide to long format
  arrange(id, DateApproved) %>%
  group_by(id) %>%
  mutate(LoanRange = cumsum(LoanRange)) %>%
  ungroup() %>%
  spread(DateApproved, LoanRange) %>% #long back to wide
  select(-id)

city_loan_sums_v3_aggregated$BusinessType <- paste(city_loan_sums_v3$BusinessType)
city_loan_sums_v3_aggregated$city_state <- paste(city_loan_sums_v3$city_state)
clean_df <- city_loan_sums_v3_aggregated[,c(90,91,1:89)]

rm(list= ls()[!(ls() %in% c('clean_df', 'corps_and_mom_pop_v2', 'completeFun'))])

us_city_lat_long <- read.csv("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/06/fatal_force/us-zip-code-latitude-and-longitude.csv", stringsAsFactors=FALSE)

us_city_lat_long$City <- toupper(us_city_lat_long$City)
us_city_lat_long$city_state <- paste0(us_city_lat_long$City,"-",us_city_lat_long$State)

clean_df$latitude <- us_city_lat_long$Latitude[match(clean_df$city_state, us_city_lat_long$city_state)]
clean_df$longitude <- us_city_lat_long$Longitude[match(clean_df$city_state, us_city_lat_long$city_state)]

clean_loan_range <- clean_df[,c(1,2,92,93,3:91)]


colnames(clean_loan_range) <- gsub("/", "", colnames(clean_loan_range))
colnames(clean_loan_range) <- gsub("(\\d{2})(\\d{2})(\\d{4})$","\\3\\1\\2", colnames(clean_loan_range))

loanRange_df_final <- completeFun(clean_loan_range, c("latitude", "longitude"))

loanRange_corps_final <- filter(loanRange_df_final, BusinessType == "Corporation")
loanRange_sp_final <- filter(loanRange_df_final, BusinessType == "Sole Proprietorship")


rm(clean_df)
rm(clean_loan_range)
rm(loanRange_df_final)

write.csv(loanRange_corps_final, "loanRange_corps_final.csv", row.names = FALSE, na = "")
write.csv(loanRange_sp_final, "loanRange_sp_final.csv", row.names = FALSE, na = "")


###################
###Jobs Retained###
###################

city_jobs_sums <- corps_and_mom_pop_v2[,-c(1)]

city_jobs_sums_v2 <- city_jobs_sums %>% 
  group_by(BusinessType, DateApproved, city_state) %>% 
  summarise(JobsRetained = sum(JobsRetained))

city_jobs_sums_v3 <- city_jobs_sums_v2 %>%
  group_by(BusinessType, DateApproved, city_state) %>%
  mutate(idx = row_number()) %>%
  spread(DateApproved, JobsRetained) %>%
  select(-idx)

city_jobs_sums_v3[is.na(city_jobs_sums_v3)] <- 0

city_jobs_sums_v3$"04/17/2020" <- 0
city_jobs_sums_v3$"04/18/2020" <- 0
city_jobs_sums_v3$"04/19/2020" <- 0
city_jobs_sums_v3$"04/20/2020" <- 0
city_jobs_sums_v3$"04/21/2020" <- 0
city_jobs_sums_v3$"04/22/2020" <- 0
city_jobs_sums_v3$"04/23/2020" <- 0
city_jobs_sums_v3$"04/24/2020" <- 0
city_jobs_sums_v3$"04/25/2020" <- 0
city_jobs_sums_v3$"04/26/2020" <- 0

city_jobs_sums_v3 <- city_jobs_sums_v3[,c(1:16,82:91,17:81)]

city_jobs_sums_v3$id <- 1:20063 #here

city_jobs_sums_v3_aggregated <- city_jobs_sums_v3 %>%
  #mutate(id = 1:nrow(.)) %>% #adding an id to identify groups
  #Error: Column `id` must be length 1 (the group size), not 20063 #was getting the following error, so added id column independendtly a few lines aboves see "here"
  gather(DateApproved, jobsRetained, -id) %>% #wide to long format
  arrange(id, DateApproved) %>%
  group_by(id) %>%
  mutate(jobsRetained = cumsum(jobsRetained)) %>%
  ungroup() %>%
  spread(DateApproved, jobsRetained) %>% #long back to wide
  select(-id)

city_jobs_sums_v3_aggregated$BusinessType <- paste(city_jobs_sums_v3$BusinessType)
city_jobs_sums_v3_aggregated$city_state <- paste(city_jobs_sums_v3$city_state)
clean_jobs_df <- city_jobs_sums_v3_aggregated[,c(90,91,1:89)]

rm(list= ls()[!(ls() %in% c('clean_jobs_df', 'corps_and_mom_pop_v2', 'completeFun'))])

us_city_lat_long <- read.csv("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/06/fatal_force/us-zip-code-latitude-and-longitude.csv", stringsAsFactors=FALSE)

us_city_lat_long$City <- toupper(us_city_lat_long$City)
us_city_lat_long$city_state <- paste0(us_city_lat_long$City,"-",us_city_lat_long$State)

clean_jobs_df$latitude <- us_city_lat_long$Latitude[match(clean_jobs_df$city_state, us_city_lat_long$city_state)]
clean_jobs_df$longitude <- us_city_lat_long$Longitude[match(clean_jobs_df$city_state, us_city_lat_long$city_state)]

clean_job_retained <- clean_jobs_df[,c(1,2,92,93,3:91)]


colnames(clean_job_retained) <- gsub("/", "", colnames(clean_job_retained))
colnames(clean_job_retained) <- gsub("(\\d{2})(\\d{2})(\\d{4})$","\\3\\1\\2", colnames(clean_job_retained))

jobsRetained_df_final <- completeFun(clean_job_retained, c("latitude", "longitude"))

jobsRetained_corps_final <- filter(jobsRetained_df_final, BusinessType == "Corporation")
jobsRetained_sp_final <- filter(jobsRetained_df_final, BusinessType == "Sole Proprietorship")


rm(clean_jobs_df)
rm(clean_job_retained)
rm(jobsRetained_df_final)

write.csv(jobsRetained_corps_final, "jobsRetained_corps_final.csv", row.names = FALSE, na = "")
write.csv(jobsRetained_sp_final, "jobsRetained_sp_final.csv", row.names = FALSE, na = "")

          
