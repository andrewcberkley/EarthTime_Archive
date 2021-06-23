setwd(file.path(Sys.getenv('my_dir'),'2021/06/historical_american_lynching_data_collection_project'))

options(java.parameters = "-Xmx12000m")

#ejiTables <- tabulizer::extract_tables("02-07-20-lynching-in-america-county-supplement.pdf", pages = c(2:20))
#df <- plyr::rbind.fill(lapply(ejiTables,function(y){as.data.frame(t(y),stringsAsFactors=FALSE)}))

county_data <- read.csv("equal_justice_initiative_lynching_in_america-confronting_the_legacy_of_racial_terror_county_data_supplement.csv")

#colnames(county_data)[3] <- "1930"

as.data.frame(table(county_data$State))

fips <- read.csv(file.path(Sys.getenv('my_dir'),'2019/04/USA_Housing/usa_fips_all.csv'))

county_data$county_state <- paste0(county_data$County,"-", county_data$State)
fips$county_state <- paste0(fips$County.or.equivalent,"-", fips$Stateor.equivalent)

county_data$FIPS <- fips[match(county_data$county_state, fips$county_state), 1]

suppressWarnings(county_data$FIPS <- sprintf("%05d", as.numeric(county_data$FIPS)))

final_df <- county_data[,c(5,3)]
colnames(final_df)[2] <- "1950"

final_df$FIPS <- sapply(final_df$FIPS , function(x) paste0("'", x)) #Leading zeros stability

write.csv(final_df, "documented_african_american_racial_terror_lynching_victims_per_county_1877-1950.csv", na = "", row.names = FALSE)