#Mapping Student Debt in America
setwd(file.path(Sys.getenv('my_dir'),'2019/08/Mapping_Student_Debt/'))

if (1 > 0){
    cat(paste0("This code reproduces the primary analysis that was the basis for the World Economic Forum’s Agenda blog piece on Mapping Student Debt in the United States. Before running this code, please note the following limitations: For student debt as reported in the U.S. Department of Education’s College Scorecard, we averaged the student debt figures among 4-year institutions based in the same county, weighting for the number of students attending. Schools with years that had missing values were filled basic linear interpolation models. We then dispersed student debt among all counties by assuming that graduates leaving those institutions migrated throughout the US according to county-level migration patterns identified using data from the U.S. Census Bureau’s 1-year American Community Survey (Migration/Geographic Mobility) based on the 1997-2016 date range. For calculating the percentage of student debt for 22-44 year olds, we combined data using the number of tax returns with the student loan interest deduction from the Internal Revenue Service’s SOI Tax Stats – Individual Income Tax Statistics – Zip Code dataset with the U.S. Census Bureau’s 1-year American Community Survey (B01001_010 - B01001_014/ZCAT5) to get a rough estimate of the number of people from the age cohort with student loans in a given zip code. Zip codes with missing values were imputed using estimates from nearby zip codes. Do you not only acknowledge and accept the limitations in this methodology, but also commit to stating them in your own analysis as well as providing proper attribution to the World Economic Forum?"))
    continue <- switch(
        menu(c("yes", "no")),
        TRUE,
        FALSE
    )
    if (continue){


#College Scorecard Data
library(plyr)
library(tidyverse)
library(httr)
library(jsonlite)
library(data.table)
library(zoo)
library(purrr)
library(readxl)
library(stringr)
library(dplyr)
library(totalcensus)


DATA_GOV_API_KEY <- Sys.getenv("DATA_GOV_API_KEY")



#[1] "{\n  \"error\": {\n    \"code\": \"API_KEY_MISSING\",\n    \"message\": \"College Scorecard requires an API Key for access. To obtain a key, visit https://api.data.gov/signup. You will receive an email with your key. When you receive this key, simply append it to your API requests with the additional parameter &api_key=xxxxxxxxxxxxx.\"\n  }\n}"

#Requests must be made over HTTPS. Try accessing the API at: https://api.data.gov/ed/collegescorecard/v1/schools?fields=school.name,id,latest.aid.median_debt.completers.overall,latest.repayment.1_yr_repayment.completers,latest.earnings.10_yrs_after_entry.working_not_enrolled.mean_earnings&page=100&api_key=KXtTgGQwp1a3Ls4x1poCHRCOkZb8hrqzGMoSb2lZ

#STRUCTRE
#The basic structure of an API call is "year.dev-category.dev-friendly-variable-name"
#The year may be any year of data available (example: 2012), or use the word latest to get the most recent data available from the API. Using the "latest" key will allow your application to access the new data as soon as it is released.
#The school category has no year.
#id, ope6_id, ope8_id and location have no category or year.


#Max Page Number is "352".... metadata total = 7058, with 20 results returned per metadata page... 7058/20 = 352.9... with page 352 returning 18 rows

#https://stackoverflow.com/questions/46188793/r-iterate-through-list-of-start-and-end-dates-and-insert-into-an-api-request


#https://www.dummies.com/programming/r/how-to-repeat-vectors-in-r/
mytable <- list()
mytable$years <- rep(c(1997:2016), each = 353) #"each" will always be +1 of page_number rep max
mytable$page_number <- rep(c(0:352), times = 20) #times will always be equal to the range of years
matchedTable <- data.table( years = mytable$years, page_number = mytable$page_number)

pb <- progress_estimated(nrow(matchedTable))

pull_scorecard <- function(year, page_number){
	pb$tick()$print()
	Sys.sleep(3)
	GET(url = paste0("https://api.data.gov/ed/collegescorecard/v1/schools?fields=ope8_id,school.carnegie_basic,school.name,school.city,school.state,school.zip,school.region_id,location.lat,location.lon,", year, ".aid.median_debt.completers.overall,", year, ".aid.median_debt.noncompleters,", year, ".aid.median_debt.income.0_30000,", year, ".aid.median_debt.income.30001_75000,", year, ".aid.median_debt.income.greater_than_75000,", year, ".aid.median_debt.first_generation_students,", year, ".aid.median_debt.non_first_generation_students,", year, ".aid.median_debt.number.overall,", year, ".aid.median_debt.number.completers,", year, ".aid.median_debt.noncompleters,", year, ".aid.loan_principal,school.degrees_awarded.predominant,id&page=", page_number, "&api_key=", DATA_GOV_API_KEY))
}

carnegie_basic <- data.table(value = c(-2, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33), label = c("Not applicable", "(Not classified)", "Associate's Colleges: High Transfer-High Traditional", "Associate's Colleges: High Transfer-Mixed Traditional/Nontraditional", "Associate's Colleges: High Transfer-High Nontraditional", "Associate's Colleges: Mixed Transfer/Career & Technical-High Traditional", "Associate's Colleges: Mixed Transfer/Career & Technical-Mixed Traditional/Nontraditional", "Associate's Colleges: Mixed Transfer/Career & Technical-High Nontraditional", "Associate's Colleges: High Career & Technical-High Traditional", "Associate's Colleges: High Career & Technical-Mixed Traditional/Nontraditional", "Associate's Colleges: High Career & Technical-High Nontraditional", "Special Focus Two-Year: Health Professions", "Special Focus Two-Year: Technical Professions", "Special Focus Two-Year: Arts & Design", "Special Focus Two-Year: Other Fields", "Baccalaureate/Associate's Colleges: Associate's Dominant", "Doctoral Universities: Very High Research Activity", "Doctoral Universities: High Research Activity", "Doctoral/Professional Universities", "Master's Colleges & Universities: Larger Programs", "Master's Colleges & Universities: Medium Programs", "Master's Colleges & Universities: Small Programs", "Baccalaureate Colleges: Arts & Sciences Focus", "Baccalaureate Colleges: Diverse Fields", "Baccalaureate/Associate's Colleges: Mixed Baccalaureate/Associate's", "Special Focus Four-Year: Faith-Related Institutions", "Special Focus Four-Year: Medical Schools & Centers", "Special Focus Four-Year: Other Health Professions Schools", "Special Focus Four-Year: Engineering Schools", "Special Focus Four-Year: Other Technology-Related Schools", "Special Focus Four-Year: Business & Management Schools", "Special Focus Four-Year: Arts, Music & Design Schools", "Special Focus Four-Year: Law Schools", "Special Focus Four-Year: Other Special Focus Institutions", "Tribal Colleges"))

degrees_awarded_predominant <- data.table(value = c(0, 1, 2, 3, 4), label = c("Not classified", "Predominantly certificate-degree granting", "Predominantly associate's-degree granting", "Predominantly bachelor's-degree granting", "Entirely graduate-degree granting"))


if (1 > 0){
    cat(paste0(
       "The process of sending requests to the U.S. Department of Education's API for this analysis will take approximately 480  minutes (8 hours). Do you want to continue?"
    ))
    continue <- switch(
        menu(c("yes", "no")),
        TRUE,
        FALSE
    )
    if (continue){

data <- Map(pull_scorecard, matchedTable$years, matchedTable$page_number) #this process will take about 8 hours
#saveRDS(data, file = "raw_college_scorecard_data.rds")
data <- lapply(path_pages, function(x) request <-GET(url = x))
#data <- readRDS("~/raw_college_scorecard_data.rds")

    } else {
        stop("You chose not to continue the process. If this was do to time constraints, please consider running this code over night. Thank you for considering using the data methodology from the World Economic Forum's Data Science team.")
    }
}


data2 <- lapply(data, function(y) response <- content(y, as = "text", encoding = "UTF-8"))
data3 <- lapply(data2, function(z) college_data <- fromJSON(z, flatten = TRUE) %>% data.frame())
combined_data_frame <- rbindlist(data3, fill = TRUE)

#https://stackoverflow.com/questions/43345821/how-to-collapse-rows-of-data
cleaner_df <- setDT(combined_data_frame)[, lapply(.SD, function(x)
                      {x <- unique(x[!is.na(x)])
                       if(length(x) == 1) as.character(x)
                       else if(length(x) == 0) NA_character_
                       else "multiple"}),
             by=results.ope8_id]

#write.csv(cleaner_df, "all_schools.csv", na = "", row.names = FALSE)

aid_median_debt_completers_overall <- cleaner_df[,c("results.ope8_id", "results.school.name", "results.school.carnegie_basic", "results.school.degrees_awarded.predominant", "results.location.lat", "results.location.lon", "results.1997.aid.median_debt.completers.overall", "results.1998.aid.median_debt.completers.overall", "results.1999.aid.median_debt.completers.overall", "results.2000.aid.median_debt.completers.overall", "results.2001.aid.median_debt.completers.overall", "results.2002.aid.median_debt.completers.overall", "results.2003.aid.median_debt.completers.overall", "results.2004.aid.median_debt.completers.overall", "results.2005.aid.median_debt.completers.overall", "results.2006.aid.median_debt.completers.overall", "results.2007.aid.median_debt.completers.overall", "results.2008.aid.median_debt.completers.overall", "results.2009.aid.median_debt.completers.overall", "results.2010.aid.median_debt.completers.overall", "results.2011.aid.median_debt.completers.overall", "results.2012.aid.median_debt.completers.overall", "results.2013.aid.median_debt.completers.overall", "results.2014.aid.median_debt.completers.overall", "results.2015.aid.median_debt.completers.overall", "results.2016.aid.median_debt.completers.overall")]

number_of_students_aid_median_debt_completers <- cleaner_df[,c("results.ope8_id", "results.school.name", "results.school.carnegie_basic", "results.school.degrees_awarded.predominant", "results.location.lat", "results.location.lon", "results.1997.aid.median_debt.number.completers", "results.1998.aid.median_debt.number.completers", "results.1999.aid.median_debt.number.completers", "results.2000.aid.median_debt.number.completers", "results.2001.aid.median_debt.number.completers", "results.2002.aid.median_debt.number.completers", "results.2003.aid.median_debt.number.completers", "results.2004.aid.median_debt.number.completers", "results.2005.aid.median_debt.number.completers", "results.2006.aid.median_debt.number.completers", "results.2007.aid.median_debt.number.completers", "results.2008.aid.median_debt.number.completers", "results.2009.aid.median_debt.number.completers", "results.2010.aid.median_debt.number.completers", "results.2011.aid.median_debt.number.completers", "results.2012.aid.median_debt.number.completers", "results.2013.aid.median_debt.number.completers", "results.2014.aid.median_debt.number.completers", "results.2015.aid.median_debt.number.completers", "results.2016.aid.median_debt.number.completers")]

#cleaner_df[,"results.school.carnegie_basic"] <- carnegie_basic[match(cleaner_df[,"results.school.carnegie_basic"], carnegie_basic[,"value"]), "label"]

#cleaner_df[,"results.school.degrees_awarded.predominant"] <- carnegie_basic[match(cleaner_df[,"results.school.degrees_awarded.predominant"], carnegie_basic[,"value"]), "label"]

data_long <- gather(aid_median_debt_completers_overall, "results.oped8", "aid.median_debt.completers.overall", 7:26, factor_key = TRUE)
colnames(data_long)[7] <- "year"
data_long <- data_long[order(data_long$results.ope8_id),]
data_long$`year` <- gsub("results.", " ", data_long$`year`)
data_long$`year` <- gsub(".aid.median_debt.completers.overall", " ", data_long$`year`)
data_long$`year` <- as.numeric(data_long$`year`)
data_long$`aid.median_debt.completers.overall` <- as.numeric(data_long$`aid.median_debt.completers.overall`)


data_student_numbers <- gather(number_of_students_aid_median_debt_completers, "results.oped8", "aid.median_debt.number.completers", 7:26, factor_key = TRUE)
colnames(data_student_numbers)[7] <- "year"
data_student_numbers <- data_student_numbers[order(data_student_numbers$results.ope8_id),]
data_student_numbers$`year` <- gsub("results.", " ", data_student_numbers$`year`)
data_student_numbers$`year` <- gsub(".aid.median_debt.number.completers", " ", data_student_numbers$`year`)
data_student_numbers$`year` <- as.numeric(data_student_numbers$`year`)
data_student_numbers$`aid.median_debt.number.completers` <- as.numeric(data_student_numbers$`aid.median_debt.number.completers`)


college_debt_student_numbers <- merge(x = data_long, y = data_student_numbers, by = c("results.ope8_id", "results.school.name", "year"), all.y = TRUE)

college_debt_student_numbers <- college_debt_student_numbers[,-c(4:7,14)]
college_debt_student_numbers <- college_debt_student_numbers[,c(1,2,5:8,3,4,9)]

#split_schools <- split(data_long, data_long$results.ope8_id)
split_schools <- split(college_debt_student_numbers, college_debt_student_numbers$results.ope8_id)
#filled_debts <- lapply(split_schools, function(g) na.approx(g[8], na.rm = FALSE))
filled_debts <- lapply(split_schools, function(g) na.approx(g[8], na.rm = FALSE))
filled_students <- lapply(split_schools, function(g) na.approx(g[9], na.rm = FALSE))


#better_df <- do.call(rbind, Map(cbind, split_schools, filled_debts))
better_df <- do.call(rbind, Map(cbind, split_schools, filled_debts, filled_students))
better_df <- better_df[,-c(8,9)]
colnames(better_df) <- c("ope8_id", "school_name", "carnegie_basic", "degrees_awarded_predominant", "latitude", "longitude", "year", "median_debt_completers", "number_of_students_in_median_debt_cohort")
better_df$carnegie_basic <- carnegie_basic$label[match(better_df$carnegie_basic, carnegie_basic$value)]
better_df$degrees_awarded_predominant <- degrees_awarded_predominant$label[match(better_df$degrees_awarded_predominant, degrees_awarded_predominant$value)]
rownames(better_df) <- NULL

school_coordinates <- cleaner_df[,c(1,10,8,9)]
colnames(school_coordinates) <- c("ope8_id", "school_name", "latitude", "longitude")

#Convert to wide format for median debt of individual schools
df <- better_df[,-c(3,9)]
df2 <- df %>%
    group_by(ope8_id, school_name, degrees_awarded_predominant, latitude, longitude) %>%
    mutate(idx = row_number()) %>%
    spread(year, median_debt_completers) %>%
    select(-idx)
df3 <- setDT(df2)[, lapply(.SD, function(x)
                      {x <- unique(x[!is.na(x)])
                       if(length(x) == 1) as.character(x)
                       else if(length(x) == 0) NA_character_
                       else "multiple"}),
             by=ope8_id]
write.csv(df3, "median_debt_all_schools.csv", na = "", row.names = FALSE)
type_list <- split(df3, df3$degrees_awarded_predominant)
for (i in seq_along(type_list)) {
    try({
        filename = paste(names(type_list)[i], ".csv")
        write.csv(type_list[[i]], filename, na = "", row.names = FALSE)
    })
}


#https://geo.fcc.gov/api/census/
pb2 <- progress_estimated(nrow(better_df))

returnCounty <- function(lat, long){
	pb2$tick()$print()
	Sys.sleep(0.5)
	GET(url = paste0("https://geo.fcc.gov/api/census/area?lat=",lat,"&lon=",long,"&format=json"))
}

if (1 > 0){
    cat(paste0(
       "The process of sending requests to the FCC's API for this analysis will take approximately 12-36 hours. Do you want to continue?"
    ))
    continue <- switch(
        menu(c("yes", "no")),
        TRUE,
        FALSE
    )
    if (continue){

countiesList <- Map(returnCounty, school_coordinates$latitude, school_coordinates$longitude) #this process will take about 8 hours
countiesList2 <- lapply(countiesList, function(y) response <- content(y, as = "text", encoding = "UTF-8"))
countiesList2[which(names(countiesList) %in% c(0,"multiple", "NA"))] <- NULL
countiesList2[c(1527,1749,3788,6565)] <- NULL #Bad Apples
countiesList3 <- lapply(countiesList2, function(z) location_data <- fromJSON(z, flatten = TRUE) %>% data.frame())
countiesDataFrame <- rbindlist(countiesList3, fill = TRUE)
countiesDataFrame <- countiesDataFrame[,c(1,2,5:9)]
saveRDS(countiesDataFrame, file = "school_coordinates.rds")
# #write.csv(countiesDataFrame, "schools_with_counties.csv", na = "", row.names = FALSE)
#countiesDataFrame <- readRDS("~/school_coordinates.rds")

    } else {
        stop("You chose not to continue the process. If this was do to time constraints, please consider running this code over night. Thank you for considering using the data methodology from the World Economic Forum's Data Science team.")
    }
}


SchoolCountyMatchTable <- better_df[,c(1,2,5:9)]
SchoolCountyMatchTable$latitude <- as.numeric(SchoolCountyMatchTable$latitude)
SchoolCountyMatchTable$latitude=format(round(SchoolCountyMatchTable$latitude,3),nsmall=3)
SchoolCountyMatchTable$longitude <- as.numeric(SchoolCountyMatchTable$longitude)
SchoolCountyMatchTable$longitude=format(round(SchoolCountyMatchTable$longitude,3),nsmall=3)

countiesDataFrame$input.lat <- as.numeric(countiesDataFrame$input.lat)
countiesDataFrame$input.lon <- as.numeric(countiesDataFrame$input.lon)
countiesDataFrame$input.lat=format(round(countiesDataFrame$input.lat,3),nsmall=3)
countiesDataFrame$input.lon=format(round(countiesDataFrame$input.lon,3),nsmall=3)
colnames(countiesDataFrame) <- c("latitude", "longitude", "county_fips", "county_name", "state_fips", "state_code", "state_name")

schoolsMatchedCounties <- merge(x = SchoolCountyMatchTable, y = countiesDataFrame, by = c("latitude", "longitude"), all.y = TRUE)

#Consider Using a Weighted Mean
#https://stackoverflow.com/questions/49992049/how-to-use-dplyr-to-calculate-a-weighted-mean-of-two-grouped-variables
#https://www.statisticshowto.datasciencecentral.com/weighted-mean/

# average_county_debt_pre_migration <- schoolsMatchedCounties %>%
# 	group_by(year, county_fips) %>%
# 	summarise(median_debt_completers = mean(median_debt_completers, na.rm = TRUE))

# colnames(average_county_debt_pre_migration) <- c("Year", "Old FIPS Code", "Average County Debt")

weighted_average <- schoolsMatchedCounties %>%
	group_by(year, county_fips) %>%
	summarise(median_debt_completers = weighted.mean(median_debt_completers, number_of_students_in_median_debt_cohort, na.rm = TRUE))

colnames(weighted_average) <- c("Year", "Old FIPS Code", "Average County Debt")	
#county_debt_pre_migration_2016 <- average_county_debt_pre_migration[grepl("2016", average_county_debt_pre_migration$`Year`),]
#weighted_average <- weighted_average[!grepl("NaN", weighted_average$`Average County Debt`),]
weighted_average <- weighted_average[grepl("2016", weighted_average$`Year`),]

#rm(list=setdiff(ls(), "weighted_average"))

#Census Migration Data
download.file("https://www2.census.gov/programs-surveys/demo/tables/geographic-mobility/2016/county-to-county-migration-2012-2016/county-to-county-migration-flows/county-to-county-2012-2016-previous-residence-sort.xlsx", destfile = "~/migration2012_2016.xlsx", mode='wb')

#download.file("https://www2.census.gov/programs-surveys/demo/tables/geographic-mobility/2012/county-to-county-migration-2008-2012/county-to-county-2008-2012-previous-residence-sort.xls", destfile = "~/migration2008_2012.xls", mode='wb')

#download.file("https://www2.census.gov/programs-surveys/demo/tables/geographic-mobility/2009/county-to-county-migration-2005-2009/county-to-county-previous-residence-sort.xls", destfile = "~/migration2005_2009.xls", mode='wb')

#migration2000 <- "https://www2.census.gov/programs-surveys/demo/tables/geographic-mobility/2000/county-to-county-flows/outtxt_flow.txt"

weighted_average <- weighted_average[grepl("2016", weighted_average$`Year`),]

sheet = excel_sheets("migration2012_2016.xlsx")
df_migration = lapply(setNames(sheet, sheet), function(x) read_excel("migration2012_2016.xlsx", sheet=x, col_names = c("Current Residence State Code", "Current Residence FIPS County Code", "Residence 1 Year Ago State/U.S. Island Area/Foreign Region Code", "Residence 1 Year Ago FIPS County Code", "State of Current Residence", "County of Current Residence", "County of Current Residence - Population 1 Year and Over - Estimate", "County of Current Residence - Population 1 Year and Over - MOE", "County of Current Residence - Nonmovers - Estimate", "County of Current Residence - Nonmovers - MOE", "County of Current Residence - Movers within United States or Puerto Rico1 - Estimate", "County of Current Residence - Movers within United States or Puerto Rico1 - MOE", "County of Current Residence - Movers within Same County - Estimate", "County of Current Residence - Movers within Same County - MOE", "County of Current Residence - Movers from Different County, Same State - Estimate", "County of Current Residence - Movers from Different County, Same State - MOE", "County of Current Residence - Movers from Different State - Estimate", "County of Current Residence - Movers from Different State - MOE", "County of Current Residence - Movers from Abroad2 - Estimate", "County of Current Residence - Movers from Abroad2 - MOE", "State/U.S. Island Area/Foreign Region of Residence 1 Year Ago", "County of Residence 1 Year Ago", "County of Residence 1 Year Ago - Population 1 Year and Over - Estimate", "County of Residence 1 Year Ago - Population 1 Year and Over - MOE", "County of Residence 1 Year Ago - Nonmovers - Estimate", "County of Residence 1 Year Ago - Nonmovers - MOE", "County of Residence 1 Year Ago - Movers within United States - Estimate", "County of Residence 1 Year Ago - Movers within United States - MOE", "County of Residence 1 Year Ago - Movers within Same County - Estimate", "County of Residence 1 Year Ago - Movers within Same County - MOE", "County of Residence 1 Year Ago - Movers to Different County, Same State - Estimate", "County of Residence 1 Year Ago - Movers to Different County, Same State - MOE", "County of Residence 1 Year Ago - Movers to Different State - Estimate", "County of Residence 1 Year Ago - Movers to Different State - MOE", "County of Residence 1 Year Ago - Movers to Puerto Rico - Estimate", "County of Residence 1 Year Ago - Movers to Puerto Rico - MOE", "Movers in County-to-County Flow - Estimate", "Movers in County-to-County Flow - MOE"),skip = 4))
df_migration = bind_rows(df_migration, .id="Sheet")
all_states <- data.table::rbindlist(df_migration)
all_states <- all_states[, c(1:6, 21, 22)]
all_states <- all_states[!grepl("Footnotes:", all_states$`Current Residence State Code`),]
all_states$`Current FIPS Code` <- paste0(all_states$`Current Residence State Code`, all_states$`Current Residence FIPS County Code`)
all_states$`Old FIPS Code` <- paste0(all_states$`Residence 1 Year Ago State/U.S. Island Area/Foreign Region Code`, all_states$`Residence 1 Year Ago FIPS County Code`)
all_states <- all_states[,c(9,6,5,10,8,7)]
all_states$`Current FIPS Code` <- str_sub(all_states$`Current FIPS Code`, -5, -1)
all_states$`Old FIPS Code` <- str_sub(all_states$`Old FIPS Code`, -5, -1)


# rm(df_migration)
# rm(sheet)

#If you run out of memory...
#https://stackoverflow.com/questions/5171593/r-memory-management-cannot-allocate-vector-of-size-n-mb
#memory.limit()
memory.limit(size=25000)

weighted_average <- schoolsMatchedCounties %>%
	group_by(year, county_fips) %>%
	summarise(median_debt_completers = weighted.mean(median_debt_completers, number_of_students_in_median_debt_cohort, na.rm = TRUE))

colnames(weighted_average) <- c("Year", "Old FIPS Code", "Average County Debt")	

weighted_average <- weighted_average[grepl("2016", weighted_average$`Year`),]
################################################################################

matched_debt <- merge(x = weighted_average, y = all_states, by = "Old FIPS Code", all.y = TRUE)
matched_debt <- matched_debt[,c(1,4,3)]

matched_debt <- na.omit(matched_debt)

matched_debt1 <- matched_debt %>%
    group_by(`Current FIPS Code`) %>%
    mutate(grouped_id = row_number())

matched_debt2 <- matched_debt1 %>%
    spread(`Current FIPS Code`, `Average County Debt`) %>%
    select(-grouped_id)

matched_debt3 <- matched_debt2 %>%
	bind_rows(summarise_all(., funs(if(is.numeric(.)) mean(., na.rm = TRUE) else "Current County Debt")))

matched_debt4 <- gather(matched_debt3[nrow(matched_debt3),], 2:length(matched_debt3), key = "County", value = "Average Debt") #Row 175955 in this case is the "county average" row
colnames(matched_debt4) <- c("County Average", "County FIPS", "Average Median Debt")
matched_debt4$`County FIPS` <- as.character(matched_debt4$`County FIPS`)

write.csv(matched_debt4, "median_debt_2016.csv", na = "", row.names = FALSE)


#IRS Zip Code Data

SOI_Tax_Stats_Individual_Income_Tax_Statistics_2016_ZIP_Code_Data <- read.csv(url("https://www.irs.gov/pub/irs-soi/16zpallagi.csv"), stringsAsFactors=FALSE)

zip_acs5 <- read_acs5year(
    year = 2016,
    states = "US",
    geo_headers = "ZCTA5",
    table_contents = c(
        "22 to 24 years = B01001_010",
        "25 to 29 years = B01001_011",
        "30 to 34 years = B01001_012",
        "35 to 39 years = B01001_013",
        "40 to 44 years = B01001_014"
    ),
    summary_level = "860"
)

cleaned_irs_data <- SOI_Tax_Stats_Individual_Income_Tax_Statistics_2016_ZIP_Code_Data[,c(2:5, 57, 58)]

colnames(cleaned_irs_data) <- c("state", "zip_code", "size_of_adjusted_gross_income", "number_of_returns","returns_with_student_loan_interest_deduction", "student_loan_interest_deduction_amount")


summed_irs_data <- aggregate(list(`size_of_adjusted_gross_income`=cleaned_irs_data$`size_of_adjusted_gross_income`,`number_of_returns`=cleaned_irs_data$`number_of_returns`, `returns_with_student_loan_interest_deduction`=cleaned_irs_data$`returns_with_student_loan_interest_deduction`, `student_loan_interest_deduction_amount`=cleaned_irs_data$`student_loan_interest_deduction_amount`), by=list(state=cleaned_irs_data$state,ZCTA5=cleaned_irs_data$zip_code), FUN=sum)

summed_irs_data <- summed_irs_data[,-c(3)]

#Adding leading zeros for zip code:
summed_irs_data$ZCTA5 <- sprintf("%05d", as.numeric(summed_irs_data$ZCTA5))
#If on OSX/Linux, use the following:
# summed_irs_data$ZCTA5 <- sprintf("%05d", summed_irs_data$ZCTA5)

summed_irs_data <- summed_irs_data[!grepl("00000", summed_irs_data$ZCTA5),]

zip_acs5$millennials <- rowSums(zip_acs5[,c(5:9)], na.rm = TRUE)

millennial_student_debt <- merge(x = zip_acs5, y = summed_irs_data, by = "ZCTA5", all.y = TRUE)
millennial_student_debt <- millennial_student_debt[,-c(2:3,5:15,20)]
millennial_student_debt$percent_with_debt <- (millennial_student_debt$returns_with_student_loan_interest_deduction)/(millennial_student_debt$millennials)


write.csv(millennial_student_debt, "millennial_student_debt.csv", na = "", row.names = FALSE)
#
##
###
####
#####
######
#######
########
#########
##########
###########
##########
#########
########
#######
######
#####
####
###
##
#

} else {
    stop("You chose not to continue the process. Thank you for considering using the data methodology from the World Economic Forum's Data Science team for your purposes.")
    }
}
