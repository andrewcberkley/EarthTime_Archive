setwd(file.path(Sys.getenv('my_dir'),'2018/10/benchmarking_data_project/'))

Bench_with_NAs <- read.csv("Bench_with_NAs.csv", stringsAsFactors=FALSE)

#Group values with identical ID into columns without summerizing them in R
#https://stackoverflow.com/questions/52394652

library(tidyverse)

#Filtering a data frame by values in a column
#https://stackoverflow.com/questions/7381455

Year_2018 <- subset(Bench_with_NAs, Year=="2018")
Year_2017 <- subset(Bench_with_NAs, Year=="2017")
Year_2016 <- subset(Bench_with_NAs, Year=="2016")
Year_2015 <- subset(Bench_with_NAs, Year=="2015")
Year_2014 <- subset(Bench_with_NAs, Year=="2014")
Year_2013 <- subset(Bench_with_NAs, Year=="2013")
Year_2012 <- subset(Bench_with_NAs, Year=="2012")
Year_2011 <- subset(Bench_with_NAs, Year=="2011")
Year_2010 <- subset(Bench_with_NAs, Year=="2010")

#Equivalence of 'vlookup' in R for multiple columns
#https://stackoverflow.com/questions/28532032

joining_years <- left_join(Bench_with_NAs, Year_2010, by = c("EcoISO3", "Year", "Index_Name", "Series_Name", "Series_Abrv"))
colnames(joining_years)[7] <- "2010"

joining_years <- left_join(joining_years, Year_2011, by = c("EcoISO3", "Year", "Index_Name", "Series_Name", "Series_Abrv"))
colnames(joining_years)[8] <- "2011"

joining_years <- left_join(joining_years, Year_2012, by = c("EcoISO3", "Year", "Index_Name", "Series_Name", "Series_Abrv"))
colnames(joining_years)[9] <- "2012"

joining_years <- left_join(joining_years, Year_2013, by = c("EcoISO3", "Year", "Index_Name", "Series_Name", "Series_Abrv"))
colnames(joining_years)[10] <- "2013"

joining_years <- left_join(joining_years, Year_2014, by = c("EcoISO3", "Year", "Index_Name", "Series_Name", "Series_Abrv"))
colnames(joining_years)[11] <- "2014"

joining_years <- left_join(joining_years, Year_2015, by = c("EcoISO3", "Year", "Index_Name", "Series_Name", "Series_Abrv"))
colnames(joining_years)[12] <- "2015"

joining_years <- left_join(joining_years, Year_2016, by = c("EcoISO3", "Year", "Index_Name", "Series_Name", "Series_Abrv"))
colnames(joining_years)[13] <- "2016"

joining_years <- left_join(joining_years, Year_2017, by = c("EcoISO3", "Year", "Index_Name", "Series_Name", "Series_Abrv"))
colnames(joining_years)[14] <- "2017"

joining_years <- left_join(joining_years, Year_2018, by = c("EcoISO3", "Year", "Index_Name", "Series_Name", "Series_Abrv"))
colnames(joining_years)[15] <- "2018"

joining_years2 <- joining_years[ -c(2:3)]

#Merge rows in a dataframe where the rows are disjoint and contain NAs
#https://stackoverflow.com/questions/14268814

library(dplyr)

# Supply lists by splicing them into dots:
# Ref: https://stackoverflow.com/a/45515491

coalesce_by_column <- function(df) {
  return(dplyr::coalesce(!!! as.list(df)))
}

#This process will take approximately 80 seconds... Please wait.
system.time(final_df <- joining_years2 %>% 
    group_by(EcoISO3, Index_Name, Series_Name, Series_Abrv) %>% 
    summarise_all(coalesce_by_column))

write.csv(final_df, "wef_benchmarking_data_formatted_4_ET_pre-subset.csv")

#Create vector of data frame subsets based on group by of columns
#https://stackoverflow.com/questions/21894906/create-vector-of-data-frame-subsets-based-on-group-by-of-columns

df.list <- split(final_df, list(final_df$Index_Name, final_df$Series_Name, final_df$Series_Abrv), drop=TRUE) 

#Remove columns that will mess up Google Sheet sync
#Delete a column in a data frame within a list
#https://stackoverflow.com/questions/12664430
df.list_1 <- lapply(df.list, function(x) x[!(names(x) %in% c("Index_Name", "Series_Name", "Series_Abrv"))])

#Export each data frame within a list to csv [duplicate]
#https://stackoverflow.com/questions/21189373/export-each-data-frame-within-a-list-to-csv
#ABERK wrapped in "try" so the files would continue to write despite error messages
for (i in seq_along(df.list_1)) {
	try({
    filename = paste(names(df.list_1)[i], ".csv")
    write.csv(df.list_1[[i]], filename, na = "", row.names = FALSE) #Write a dataframe to csv file with value of NA as blank: https://stackoverflow.com/questions/20968717 #	Have write.csv write csv without observation number: http://r.789695.n4.nabble.com/Have-write-csv-write-csv-without-observation-number-td4030672.html
    })
}

#Final Notes: 
#A large portion of the "Series_Name"s have the ":" or the "/" characters and therefore will NOT successfully write the .csv file for those specific cases... Be sure to remove the ":" or the "/" in these cases and replace with another character such as "-"
#The "NO2" and "CH4" did not have "Series_Names" and thus produced "#NAs"... The "#" was preventing succesful writing of the file; therefore, simple remove these cases from the original file