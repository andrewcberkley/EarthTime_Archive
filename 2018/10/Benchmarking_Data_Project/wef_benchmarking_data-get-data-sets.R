setwd(file.path(Sys.getenv('my_dir'),'2018/10/benchmarking_data_project/WEF_IndexData/'))

source("functions.R")

update <- FALSE
dirpath <- getwd()

dt_all <- XLConnect::loadWorkbook("WEF_Dictionaries_20180314.xlsx")
XLConnect::setMissingValue(dt_all, value = NA)
lst_series <- XLConnect::readWorksheet(dt_all, sheet = "Series")
lst_queries <- XLConnect::readWorksheet(dt_all, sheet = "ListQueries")


# =================================
# Retrieve a data series in the DB
# =================================

# example of a generic query to retrieve the data
# -----------------------------------------------

df <- get_eco_data(
	lst_queries$indexId[1], 
	lst_queries$edition[1], 
	lst_queries$seriesId[1],
	"All",
	update
	)

# call first looks if file available in Files/
# if not, performs the query to the server again
# to force update, set last parameter to TRUE
# to get for a specific country, change All by country code

# if you want to get all data at once

load("all-combined-data.RData")
df_all <- dt
if (update) df_all <- create_all_df(lst_map)

# search and retrive available data by map
# -----------------------------------------

df_map <- get_series_by_map(lst_queries, "Future of Production")

df_ser <- get_eco_data(
	df_map$indexId[1], 
	df_map$edition[1], 
	df_map$seriesId[1],
	"All",
	update
	)


# Getting hard indices

df1_gdpppp <- get_eco_data("GCI", "2012-2013", "GDPPPP","ARG",FALSE)
df1_gdpppp <- rbind(df1_gdpppp, get_eco_data("GCI", "2013-2014", "GDPPPP","ARG",FALSE))
df1_gdpppp <- rbind(df1_gdpppp, get_eco_data("GCI", "2014-2015", "GDPPPP","ARG",FALSE))
df1_gdpppp <- rbind(df1_gdpppp, get_eco_data("GCI", "2015-2016", "GDPPPP","ARG",FALSE))
df1_gdpppp <- rbind(df1_gdpppp, get_eco_data("GCI", "2016-2017", "GDPPPP","ARG",FALSE))
df1_gdpppp <- rbind(df1_gdpppp, get_eco_data("GCI", "2017-2018", "GDPPPP","ARG",FALSE))
df1_gdpppp <- rbind(df1_gdpppp, get_eco_data("GCI4", "2017-2018", "GDPPPP","ARG",FALSE))