setwd("C:/Users/ABERK/Box/The_Definitive_ABERK_Data_Science_Folder/EarthTime_Archive/2020/02/Costs_of_Climate_Change")

#High-re-regions-simplified.topo.json contains the shapefile for Climate Impact Lab's 24,378 subnational regions, corresponding to ‘hierid’ column in each CSV file
# library(geojsonio)
# cil_highres_regions_simple <- topo2geo("./Climate_Impact_Lab_Original_Data_Resources/high-res-regions-simplified.topo.json")
# geojson_write(cil_highres_regions_simple, file = "CIL_HighRes_Regions.geojson")
# simple <- ms_simplify(cil_highres_regions_simple)
# geojson_write(simple, file = "CIL_HighRes_Regions_Super_Duper_Simple.geojson")

#Climate Impact Lab Data Overview:
# o	Data for 2 emissions scenarios (RCP4.5, RCP8.5), three time periods (1986-2005, 2020-2039, 2040-2059, 2080-2099), and three probabilities (5%/median/95%). Included are both ‘absolute’ estimates and ‘change-from hist.’ 
# o	Tas-annual: daily average temp
# o	Tasmin-under-32F: annual days with min temp below freezing
# o	Tasmax-over-95F: annual days with max temp above 95F
# o	Tas-seasonal: seasonal average daily temperature for 4 seasons
# 	o	DJF: Dec-Jan-Feb
# 	o	MAM: March-Apr-May
# 	o	JJA: June-July-August
# 	o	SON: Sept-Oct-Nov

library(dplyr)
library(magrittr)
library(weathermetrics)

#For emissions scenario RCP4.5
#"The RCP 4.5 emissions scenario [uses] GFDL's CM3 model. The CM3 is just one of many climate models that are analyzed to make predictions about our changing climate. The RCP 4.5 scenario is a stabilization scenario, which means the radiative forcing level stabilizes at 4.5 W/m2 before 2100 by employment of a range of technologies and strategies for reducing greenhouse gas emissions." - Climate Model: Temperature Change (RCP 4.5) - 2006 - 2100.... https://sos.noaa.gov/datasets/climate-model-temperature-change-rcp-45-2006-2100/

#For emissions scenario RCP8.5
#"RCP8. 5 is a so-called 'baseline' scenario that does not include any specific climate mitigation target. The greenhouse gas emissions and concentrations in this scenario increase considerably over time, leading to a radiative forcing of 8.5 W/m2 at the end of the century." - RCP 8.5—A scenario of comparatively high greenhouse gas emissions... Authors: Keywan Riahi, Shilpa Rao, Volker Krey, Cheolhung Cho, Vadim Chirkov, Guenther Fischer, Georg Kindermann, Nebojsa Nakicenovic, Peter Rafaj (https://link.springer.com/article/10.1007/s10584-011-0149-y)

#climate_impact_list <- list.files(path="Climate_Impact_Lab_Original_Data_Resources/", pattern="^global_tas-annual_rcp85.*absolute_degF_percentiles\\.csv", full.names=TRUE)  

#summertime temperatures
climate_impact_list <- list.files(path="Climate_Impact_Lab_Original_Data_Resources/", pattern="^global_tas-seasonal_JJA_rcp85.*absolute_degF_percentiles\\.csv", full.names=TRUE) 

climate_impact_dataframes <- sapply(climate_impact_list, 
                function(x)read.table(file=paste0(x),
                                      fill = TRUE,
                                      header=TRUE,
                                      sep=",",
                                      dec = ".",
                                      stringsAsFactors = FALSE), 
                USE.NAMES = TRUE, 
                simplify = FALSE)

correct_names <- c("hierid", "0.05", "0.5", "0.95")
climate_impact_dataframes_v2 <- lapply(climate_impact_dataframes, setNames, nm = correct_names)

rm(climate_impact_list)
rm(correct_names)
rm(climate_impact_dataframes)

ci_df <- purrr::reduce(climate_impact_dataframes_v2, left_join, by = "hierid")

colnames(ci_df) <- c("hierid", "1986-2005: 0.05", "1986-2005: 0.5", "1986-2005: 0.95", "2020-2039: 0.05", "2020-2039: 0.5", "2020-2039: 0.95", "2040-2059: 0.05", "2040-2059: 0.5", "2040-2059: 0.95", "2080-2099: 0.05", "2080-2099: 0.5", "2080-2099: 0.95")

#Convert from CIL's original fahrenheit numbers to celsius #Conversions are based on the US National Weather Service's online heat index calculator equations
ci_df[,2:13] <- fahrenheit.to.celsius(ci_df[,2:13], round = 2)

#Subset dataframe by probabilities
five_percent_probability <- ci_df[ , grepl( "hierid|: 0.05" , names( ci_df ) ) ]
fifty_percent_probability <- ci_df[ , grep( "hierid|: 0.5" , names( ci_df ) ) ]
ninety_five_percent_probability <- ci_df[ , grepl( "hierid|: 0.95" , names( ci_df ) ) ]

#colnames(ninety_five_percent_probability) <- c("hierid", 2005, 2039, 2059, 2099)
colnames(fifty_percent_probability) <- c("hierid", 2005, 2039, 2059, 2099)

temp_linear_interpolate0 <- function(y1, y2, side) {
    if (side==0) {return(y1)}
    else {return(y2)}
}

temp_linear_interpolate1 <- function(x1, x2, y1, y2, val) {
    slope <- (y2-y1)/(x2-x1)
    return(y1+(val-x1)*slope)
}

c_names <- c("hierid", 2005:2099)

list_edges <- rbind(
    cbind(2005, 2039),
    cbind(2039, 2059),
    cbind(2059, 2099))

get_interpolated_temperatures <- function(my.df, type) {

    k <- 2
  
    for (i in 1:nrow(list_edges)) {

        x1 <- list_edges[i,1]
        x2 <- list_edges[i,2]

        for (j in 1:(x2-x1-1)) {

            my.df <- cbind(my.df, apply(
                my.df, 1, 
                function(x) {
                    y1 <- as.numeric(x[k])
                    y2 <- as.numeric(x[k+1])
                    if (type==0) {
                        if (is.na(y1) | is.na(y2)) {return(NA)}
                        else {return(temp_linear_interpolate0(y1, y2, 0))}
                    } else if (type==1) {
                        if (is.na(y1) | is.na(y2)) {return(NA)}
                        else {return(temp_linear_interpolate1(x1, x2, y1, y2, x1+j))}
                    }
                }))
                colnames(my.df)[ncol(my.df)] <- as.character(x1+j)
            }

        k <- k+1
    }

    return(my.df)
}

#Takes around five minutes to interpolate
fifty_percent_probability_filled_temperatures <- get_interpolated_temperatures(fifty_percent_probability, 1)

#Sorting years in order
fifty_percent_probability_filled_temperatures <- fifty_percent_probability_filled_temperatures[,c_names]
fifty_percent_probability_filled_temperatures_v2 <- fifty_percent_probability_filled_temperatures
fifty_percent_probability_filled_temperatures_v2[,2:96] <- round(fifty_percent_probability_filled_temperatures_v2[,2:96],digits=3)
write.csv(fifty_percent_probability_filled_temperatures_v2, "50_percent_probability_RCP85_tas-seasonal_JJA.csv", row.names = FALSE)
