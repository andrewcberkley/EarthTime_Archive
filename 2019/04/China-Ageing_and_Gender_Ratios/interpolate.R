

source("utils.R")

rundataprocessing <- FALSE
save <- FALSE

c_names <- c(
    "ISO3","1990","1991","1992","1993","1994","1995",
    "1996","1997","1998","1999","2000","2001","2002",
    "2003","2004","2005","2006","2007","2008","2009",
    "2010","2011","2012","2013","2014","2015","2016","2017")

# Loading data

if (rundataprocessing) {
    cat("Running data cleaning...\n")
    source("cleandata.R")
}

load("./Final_Data/all_migrant_interpol_none.RData")
load("./Final_Data/female_migrant_interpol_none.RData")

# Get new interpolated values

dt1_pol0 <- get_interpolated_values(dt1_countries_sel, 0)
dt2_pol0 <- get_interpolated_values(dt2_countries_sel, 0)
dt1_pol1 <- get_interpolated_values(dt1_countries_sel, 1)
dt2_pol1 <- get_interpolated_values(dt2_countries_sel, 1)

# Restructure columns

dt1_pol0 <- dt1_pol0[,c_names]
dt2_pol0 <- dt2_pol0[,c_names]
dt1_pol1 <- dt1_pol1[,c_names]
dt2_pol1 <- dt2_pol1[,c_names]

# Save files

if (save) {
    date <- gsub("-", "", Sys.Date())
    readr::write_csv(dt1_pol0,paste0("./Final_Data/",date,"_all_migrant_interpol_pol0.csv"))
    readr::write_csv(dt2_pol0,paste0("./Final_Data/",date,"_female_migrant_interpol_pol0.csv"))
    readr::write_csv(dt1_pol1,paste0("./Final_Data/",date,"_all_migrant_interpol_pol1.csv"))
    readr::write_csv(dt2_pol1,paste0("./Final_Data/",date,"_female_migrant_interpol_pol1.csv"))
}

# Creating a long table format for plotting

g_dt1_pol0 <- plot_curve(dt1_pol0,c("USA"))
g_dt1_pol1 <- plot_curve(dt1_pol1,c("USA"))

g_dt2_pol0 <- plot_curve(dt2_pol0,c("USA"))
g_dt2_pol1 <- plot_curve(dt2_pol1,c("USA"))