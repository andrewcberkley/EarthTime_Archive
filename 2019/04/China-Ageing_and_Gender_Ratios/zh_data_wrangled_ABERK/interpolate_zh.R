#Inspired by PSAO's original interpolation functions for the migration EarthTime data

source("C:/Users/ABERK/Desktop/zh_data_wrangled_ABERK/utils_zh.R")

rundataprocessing <- FALSE
save <- FALSE

c_names <- c(
    "GB_DIST","1982","1983","1984","1985","1986","1987",
    "1988","1989","1990","1991","1992","1993","1994",
    "1995","1996","1997","1998","1999","2000","2001",
    "2002","2003","2004","2005","2006","2007","2008","2009", "2010")

# Loading data

if (rundataprocessing) {
    cat("Running data cleaning...\n")
    source("cleandata.R")
}

`65andUp_Final` <- readRDS("C:/Users/ABERK/Desktop/zh_data_wrangled_ABERK/65andUp_Final2.rds")
`SexRatio_Final` <- readRDS("C:/Users/ABERK/Desktop/zh_data_wrangled_ABERK/SexRatio_Final2.rds")
`TotalPopulation_Final` <- readRDS("C:/Users/ABERK/Desktop/zh_data_wrangled_ABERK/TotalPopulation_Final2.rds")
`PopNorm_Final` <- readRDS("C:/Users/ABERK/Desktop/zh_data_wrangled_ABERK/PopNorm_Final2.rds")

# Get new interpolated values

# dt1_pol0 <- get_interpolated_values(dt1_countries_sel, 0) #"0" keeps the values constant?
# dt2_pol0 <- get_interpolated_values(dt2_countries_sel, 0) #"0" keeps the values constant?
# dt1_pol1 <- get_interpolated_values(dt1_countries_sel, 1)
# dt2_pol1 <- get_interpolated_values(dt2_countries_sel, 1)

TotalPop_Interpolated_Final <- get_interpolated_values(TotalPopulation_Final, 1)
AgeingPopulation_Interpolated_Final <- get_interpolated_values(`65andUp_Final`, 1)
SexRatio_Interpolated_Final <- get_interpolated_values(SexRatio_Final, 1)
PopNorm_Interpolated_Final <- get_interpolated_values(PopNorm_Final, 1)

# Restructure columns

# dt1_pol0 <- dt1_pol0[,c_names]
# dt2_pol0 <- dt2_pol0[,c_names]
# dt1_pol1 <- dt1_pol1[,c_names]
# dt2_pol1 <- dt2_pol1[,c_names]

TotalPop_Interpolated_Final <- TotalPop_Interpolated_Final[,c_names]
AgeingPopulation_Interpolated_Final <- AgeingPopulation_Interpolated_Final[,c_names]
SexRatio_Interpolated_Final <- SexRatio_Interpolated_Final[,c_names]
PopNorm_Interpolated_Final <- PopNorm_Interpolated_Final[,c_names]

# Save files

write.csv(TotalPop_Interpolated_Final, "TotalPopulation_Interpolated_FinalV2.csv", row.names = FALSE)
write.csv(AgeingPopulation_Interpolated_Final, "AgeingPopulation_Interpolated_FinalV2.csv", row.names = FALSE)
write.csv(SexRatio_Interpolated_Final, "SexRatio_Interpolated_FinalV2.csv", row.names = FALSE)
write.csv(PopNorm_Interpolated_Final, "PopNorm_Interpolated_FinalV2.csv", row.names = FALSE)

# if (save) {
#     date <- gsub("-", "", Sys.Date())
#     readr::write_csv(dt1_pol0,paste0("./Final_Data/",date,"_all_migrant_interpol_pol0.csv"))
#     readr::write_csv(dt2_pol0,paste0("./Final_Data/",date,"_female_migrant_interpol_pol0.csv"))
#     readr::write_csv(dt1_pol1,paste0("./Final_Data/",date,"_all_migrant_interpol_pol1.csv"))
#     readr::write_csv(dt2_pol1,paste0("./Final_Data/",date,"_female_migrant_interpol_pol1.csv"))
# }

# # Creating a long table format for plotting

# g_dt1_pol0 <- plot_curve(dt1_pol0,c("USA"))
# g_dt1_pol1 <- plot_curve(dt1_pol1,c("USA"))

# g_dt2_pol0 <- plot_curve(dt2_pol0,c("USA"))
# g_dt2_pol1 <- plot_curve(dt2_pol1,c("USA"))