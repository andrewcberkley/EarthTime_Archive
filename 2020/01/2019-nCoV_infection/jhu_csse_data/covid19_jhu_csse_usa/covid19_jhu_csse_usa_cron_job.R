# setwd("C:/Users/ABERK/Box/Data_Science_Exploration/ABERK/ABERK_Archive/EarthTime_Archive/2020/01/2019-nCoV_infection")

# library(tibble)

# `covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse` <- read.csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv")

# usa_states_list <- c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "District of Columbia","Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming")

# destroyX = function(df) {
# #https://stackoverflow.com/questions/10441437/why-am-i-getting-x-in-my-column-names-when-reading-a-data-frame
#   f = df
#   for (col in c(1:ncol(f))){ #for each column in dataframe
#     if (startsWith(colnames(f)[col], "X") == TRUE)  { #if starts with 'X' ..
#       colnames(f)[col] <- substr(colnames(f)[col], 2, 100) #get rid of it
#     }
#   }
#   assign(deparse(substitute(df)), f, inherits = TRUE) #assign corrected data to original name
# }

# destroyX(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`)

# `covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse` <- dplyr::filter(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`, grepl("US", Country.Region))

# `covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse` <- `covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`[,-2]


# `covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse` <- add_column(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`, `1.21.20` = 0, .after = "Long")

# #Remove State Level Totals
# `covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse` <- `covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`[ `covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`$Province.State %in% usa_states_list, ]

# colnames(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`) <- gsub("\\.", "/", colnames(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`))

# colnames(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`) <- strptime(colnames(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`), "%m/%d/%Y")

# colnames(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`)[1] <- "USA_Coordinates"
# colnames(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`)[2] <- "Latitude"
# colnames(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`)[3] <- "Longitude"

# colnames(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`) <- gsub("0020-", "2020-", colnames(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`))

# colnames(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`) <- gsub("\\-", "", colnames(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`))

# sum(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`[,ncol(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`)])

# print(paste0("The number of COVID-19 cases in the United States has now reached ", sum(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`[,ncol(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`)]), " as reported by the US Centers for Disease Control and Prevention as of ", Sys.time(), " according to JHU CSSE data."))

# `covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse` <- `covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`[order(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`$USA_Coordinates),]

# write.csv(`covid-19_usa_coordinates_cdc_confirmed_cases_jhu_csse`, "state_level_cases_march_18.csv", row.names = FALSE, na = "")