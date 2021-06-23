setwd(file.path(Sys.getenv('my_dir'),'2021/06/historical_american_lynching_data_collection_project'))

options(java.parameters = "-Xmx12000m")
library(tabulizer)

#ejiTables <- extract_tables("02-07-20-lynching-in-america-county-supplement.pdf", pages = c(2:20))
#df <- plyr::rbind.fill(lapply(ejiTables,function(y){as.data.frame(t(y),stringsAsFactors=FALSE)}))

county_data <- read.csv("equal_justice_initiative_lynching_in_america-confronting_the_legacy_of_racial_terror_county_data_supplement.csv")