library(magrittr)

code_names <- c(
    "GeographicalClassification", "ISO3", "ISO2")

dt1_names <- c(
    "Order","GeographicalClassification","Notes","Code","Type",
    "1990.A","1995.A","2000.A","2005.A","2010.A","2015.A","2017.A",
    "1990.M","1995.M","2000.M","2005.M","2010.M","2015.M","2017.M",
    "1990.F","1995.F","2000.F","2005.F","2010.F","2015.F","2017.F")

dt1_types <- c(
    "character","character","character","character","character",
    "numeric","numeric","numeric","numeric","numeric","numeric","numeric",
    "numeric","numeric","numeric","numeric","numeric","numeric","numeric",
    "numeric","numeric","numeric","numeric","numeric","numeric","numeric"
)

dt2_names <- c(
    "Order","GeographicalClassification","Notes","Code","Type",
    "1990.F","1995.F","2000.F","2005.F","2010.F","2015.F","2017.F")

dt2_types <- c(
    "character","character","character","character","character",
    "numeric","numeric","numeric","numeric","numeric","numeric","numeric"
)

code <- readr::read_csv(
    "~/Box/Data_Science_Exploration/Common/EarthTime_Resources/ISO_Country_Code.csv",
    col_types = readr::cols(), 
    na = c("", "NA"))

dt1 <- XLConnect::readWorksheetFromFile(
    "./Data/UN_MigrantStockTotal_2017.xlsx",
    sheet=4,
    colTypes = dt1_types,
    header = FALSE, 
    startCol = 1, 
    startRow = 17)

dt2 <- XLConnect::readWorksheetFromFile(
    "./Data/UN_MigrantStockTotal_2017.xlsx",
    sheet=5,
    colTypes = dt2_types,
    header = FALSE, 
    startCol = 1, 
    startRow = 17)

colnames(code) <- code_names
colnames(dt1) <- dt1_names
colnames(dt2) <- dt2_names

dt1_countries <- dt1 %>% dplyr::left_join(code, by="GeographicalClassification")
dt2_countries <- dt2 %>% dplyr::left_join(code, by="GeographicalClassification")

dt1_missingcode <- dt1_countries[is.na(dt1_countries$ISO3),2]
dt2_missingcode <- dt2_countries[is.na(dt2_countries$ISO3),2]

# Selecting the data we want for Earthtime

dt1_countries_sel <- dt1_countries[!is.na(dt1_countries$ISO3),c(27, 6:12)]
dt2_countries_sel <- dt2_countries[!is.na(dt2_countries$ISO3),c(13, 6:12)]

# Set uniform precision accross all columns

for (i in 2:ncol(dt1_countries_sel)) {
    for (j in 1:nrow(dt1_countries_sel)) {
        if (!is.na(dt1_countries_sel[j,i])) {
            #cat("i=",i,"j=",j,"\n")
            dt1_countries_sel[j,i] <- as.numeric(format(round(dt1_countries_sel[j,i], 4), nsmall = 4))
        }
    }
}

for (i in 2:ncol(dt2_countries_sel)) {
    for (j in 1:nrow(dt2_countries_sel)) {
        if (!is.na(dt2_countries_sel[j,i])) {
            dt2_countries_sel[j,i] <- as.numeric(format(round(dt2_countries_sel[j,i], 4), nsmall = 4))
        }
    }
}

colnames(dt1_countries_sel) <- c("ISO3", "1990","1995","2000","2005","2010","2015","2017")
colnames(dt2_countries_sel) <- c("ISO3", "1990","1995","2000","2005","2010","2015","2017")

dt1_countries_sel <- dt1_countries_sel %>% dplyr::arrange(ISO3)
dt2_countries_sel <- dt2_countries_sel %>% dplyr::arrange(ISO3)

date <- gsub("-", "", Sys.Date())
save(dt1_countries_sel, file=paste0("./Final_Data/",date,"_all_migrant_interpol_none.RData"))
save(dt2_countries_sel, file=paste0("./Final_Data/",date,"_female_migrant_interpol_none.RData"))
save(dt1_countries_sel, file="./Final_Data/all_migrant_interpol_none.RData")
save(dt2_countries_sel, file="./Final_Data/female_migrant_interpol_none.RData")
readr::write_csv(dt1_countries_sel,paste0("./Final_Data/",date,"_all_migrant_interpol_none.RData"))
readr::write_csv(dt2_countries_sel,paste0("./Final_Data/",date,"_female_migrant_interpol_none.RData"))